#!/usr/bin/env python3
"""Phase 1 — Anki .apkg -> local JSON flashcard parser for WardReady.

Reads the .apkg files in the configured source dir, unzips each to a temp
folder, opens the SQLite collection, and emits a JSON array of:
    [{"deck": "...", "front": "...", "back": "..."}, ...]

NO Supabase writes. Output is scripts/apkg_flashcards.json plus a
human-readable log (scripts/apkg_phase1_report.txt).

Rules applied (from approved Phase 1 plan):
  * Exclude MSB Pharm (its only note is an import error message).
  * Exclude Image Occlusion note types entirely (no text representation).
  * Basic cards: field0 -> front, field1 -> back (use the model's REAL field
    order, not hardcoded 0/1).
  * Cloze cards: each {{cN::}} deletion -> its own front/back pair.
      hint syntax {{c1::answer::hint}} -> front shows [hint], back shows answer.
  * Strip HTML (tags incl. <img>) to plain text; preserve line breaks.
  * Drop any card whose front or back is empty/near-empty (<=2 chars) AFTER
    stripping — and log it (the answer depended on an image we can't show).
  * Keep the full Parent::Child deck path verbatim in deckName.
  * source_article_id is null (not tied to an article) — added in Phase 3 SQL.

Usage:
  python3 import_apkg.py
"""
import os
import re
import io
import json
import zipfile
import sqlite3
import zstandard
import shutil
import tempfile
import html
from bs4 import BeautifulSoup

SRC_DIR = r"C:\wr_work\wardready\apkg"
OUT_JSON = os.path.join(os.path.dirname(os.path.abspath(__file__)), "apkg_flashcards.json")
REPORT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "apkg_phase1_report.txt")

# Decks / files we explicitly exclude.
EXCLUDE_FILES = {"MSB Pharm Flashcards"}  # only note is an Anki error message
# Note-type names that are image-based and cannot be represented as text.
EXCLUDE_MODEL_NAMES = {"Image Occlusion", "Image Occlusion Enhanced"}

SEP = "\x1f"
CLOZE_RE = re.compile(r"\{\{c(\d+)::(.*?)(?:::(.*?))?\}\}", re.DOTALL)


def find_db_dir(file_path):
    tmp = tempfile.mkdtemp(prefix="apkg_")
    with zipfile.ZipFile(file_path, "r") as zf:
        zf.extractall(tmp)
    for f in os.listdir(tmp):
        if f.startswith("collection.anki"):
            return os.path.join(tmp, f), f, tmp
    return None, None, tmp


def open_db(path, fmt):
    if fmt.endswith("b"):
        with open(path, "rb") as fh:
            data = zstandard.ZstdDecompressor().decompress(fh.read())
        return sqlite3.connect(io.BytesIO(data))
    return sqlite3.connect(path)


def clean_html(raw):
    """Strip HTML to plain text, preserving line breaks for <br>/<div>/<p>."""
    if raw is None:
        return ""
    # Drop <img ...> entirely.
    raw = re.sub(r"<img\b[^>]*>", "", raw, flags=re.IGNORECASE)
    raw = re.sub(r"<br\s*/?>", "\n", raw, flags=re.IGNORECASE)
    raw = re.sub(r"<div\b[^>]*>", "\n", raw, flags=re.IGNORECASE)
    raw = re.sub(r"</div>", "\n", raw, flags=re.IGNORECASE)
    raw = re.sub(r"<p\b[^>]*>", "\n", raw, flags=re.IGNORECASE)
    raw = re.sub(r"</p>", "\n", raw, flags=re.IGNORECASE)
    raw = re.sub(r"<li\b[^>]*>", "\n- ", raw, flags=re.IGNORECASE)
    text = BeautifulSoup(raw, "html.parser").get_text()
    text = html.unescape(text)
    # Normalize blank lines / whitespace.
    lines = [ln.strip() for ln in text.split("\n")]
    text = "\n".join(lines)
    text = re.sub(r"\n{3,}", "\n\n", text).strip()
    return text


def is_meaningful(text):
    return len(text.strip()) > 2


def split_fields(flds):
    return flds.split(SEP)


def cloze_cards(text_field, extra_field, log):
    """Return list of (front, back) for a cloze note. front hides answers."""
    # Find all cloze numbers present.
    found = CLOZE_RE.findall(text_field)
    numbers = sorted({int(n) for n, _, _ in found})
    cards = []
    for num in numbers:
        # Build the prompt (all other cloze answers hidden).
        def replace_prompt(m):
            n, ans, hint = m.group(1), m.group(2), m.group(3)
            if int(n) == num:
                if hint:
                    return f"[{hint}]"
                return "[...]"
            return "[...]"

        front = CLOZE_RE.sub(replace_prompt, text_field)
        # Build the answer (this cloze revealed).
        def replace_back(m):
            n, ans, hint = m.group(1), m.group(2), m.group(3)
            if int(n) == num:
                return ans.strip()
            return "[...]"

        back = CLOZE_RE.sub(replace_back, text_field)
        front = clean_html(front)
        back = clean_html(back)
        # Append Extra as back context if present.
        extra = clean_html(extra_field)
        if extra:
            back = back + ("\n\n" + extra if back else extra)
        cards.append((front, back))
    return cards


def basic_cards(fields, field_names, log):
    """Front/Back from the model's actual field order."""
    # Locate fields by common names; fall back to 0/1.
    def idx(name):
        try:
            return field_names.index(name)
        except ValueError:
            return None

    fi = idx("Front")
    bi = idx("Back")
    if fi is None or bi is None:
        fi, bi = 0, 1
    front = clean_html(fields[fi]) if fi < len(fields) else ""
    back = clean_html(fields[bi]) if bi < len(fields) else ""
    return [(front, back)]


def process_file(file_path, base_name, log):
    db_path, fmt, tmp = find_db_dir(file_path)
    cards = []
    dropped = []
    try:
        if db_path is None:
            log.append(f"  !! {base_name}: no collection db found")
            return cards, dropped
        con = open_db(db_path, fmt)
        cur = con.cursor()
        cur.execute("SELECT decks, models FROM col")
        decks_json, models_json = cur.fetchone()
        decks = json.loads(decks_json)
        models = json.loads(models_json)

        # Map mid -> model info
        model_map = {}
        for mid, mval in models.items():
            flds = mval.get("flds", [])
            field_names = [f.get("name", "") for f in flds]
            is_cloze = mval.get("type", 0) == 1
            model_map[mid] = {
                "name": mval.get("name", ""),
                "is_cloze": is_cloze,
                "field_names": field_names,
            }

        # deck id -> name
        deck_name = {}
        for did, dval in decks.items():
            deck_name[str(did)] = dval.get("name", f"id:{did}")

        # notes joined with cards to get deck (did). A note may map to several
        # cards in possibly different decks; use card.did for the real deck.
        cur.execute(
            "SELECT n.id, n.mid, n.flds, c.did "
            "FROM notes n JOIN cards c ON c.nid = n.id"
        )
        rows = cur.fetchall()
        for nid, mid, flds, did in rows:
            m = model_map.get(str(mid))
            if m is None:
                log.append(f"  !! note {nid}: unknown model {mid}")
                continue
            if m["name"] in EXCLUDE_MODEL_NAMES:
                dropped.append((base_name, deck_name.get(str(did), "?"),
                                "Image Occlusion model excluded"))
                continue
            dn = deck_name.get(str(did), "Unknown")
            fields = split_fields(flds)
            if m["is_cloze"]:
                pairs = cloze_cards(fields[0] if fields else "",
                                    fields[1] if len(fields) > 1 else "", log)
            else:
                pairs = basic_cards(fields, m["field_names"], log)
            for front, back in pairs:
                if not is_meaningful(front) or not is_meaningful(back):
                    dropped.append((base_name, dn,
                                    f"empty after strip | front={front!r} back={back!r}"))
                    continue
                cards.append({"deck": dn, "front": front, "back": back})
        con.close()
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
    return cards, dropped


def main():
    all_cards = []
    all_dropped = []
    report = []
    for fname in sorted(os.listdir(SRC_DIR)):
        if not fname.endswith(".apkg"):
            continue
        base = os.path.splitext(fname)[0]
        path = os.path.join(SRC_DIR, fname)
        report.append(f"\n===== {fname} =====")
        if base in EXCLUDE_FILES:
            report.append("  EXCLUDED (rule: error-message deck)")
            all_dropped.append((base, "-", "file excluded"))
            continue
        cards, dropped = process_file(path, base, report)
        all_cards.extend(cards)
        all_dropped.extend(dropped)
        report.append(f"  produced cards: {len(cards)}   dropped: {len(dropped)}")

    # Per-deck counts
    per_deck = {}
    for c in all_cards:
        per_deck[c["deck"]] = per_deck.get(c["deck"], 0) + 1

    # Spot-check flags: suspicious lengths, duplicates.
    short = [c for c in all_cards if len(c["front"]) < 8 or len(c["back"]) < 8]
    seen = set()
    dups = 0
    for c in all_cards:
        key = (c["deck"], c["front"], c["back"])
        if key in seen:
            dups += 1
        seen.add(key)

    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(all_cards, f, ensure_ascii=False, indent=0)

    report.append("\n" + "=" * 60)
    report.append(f"TOTAL CARDS PRODUCED: {len(all_cards)}")
    report.append(f"TOTAL DROPPED: {len(all_dropped)}")
    report.append(f"DUPLICATE-LIKE (same deck+front+back): {dups}")
    report.append(f"SHORT (<8 char front/back): {len(short)}")
    report.append(f"\nDISTINCT DECKS: {len(per_deck)}")
    report.append("\n--- PER-DECK COUNTS ---")
    for dn, cnt in sorted(per_deck.items(), key=lambda x: -x[1]):
        report.append(f"  {cnt:>6}  {dn}")

    report.append("\n--- DROPPED CARDS (sample, first 60) ---")
    for b, dn, why in all_dropped[:60]:
        report.append(f"  [{b}] {dn}: {why}")

    with open(REPORT, "w", encoding="utf-8") as f:
        f.write("\n".join(report))

    print(f"Wrote {len(all_cards)} cards to {OUT_JSON}")
    print(f"Report: {REPORT}")


if __name__ == "__main__":
    main()
