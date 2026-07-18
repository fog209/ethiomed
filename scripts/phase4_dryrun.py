#!/usr/bin/env python3
"""Phase 4 DRY RUN — convert live article content old-shape -> new shape.

Read-only: pulls every row from `articles`, prints the before/after diff for
each, and writes NOTHING back. Requires the anon key (read access is public).

Usage:
  python3 phase4_dryrun.py
"""
import json
import os
import sys
import urllib.request
import urllib.error

SUPABASE_URL = os.environ.get(
    "SUPABASE_URL", "https://kxcdzlyirdonkipcymvc.supabase.co"
)
ANON_KEY = os.environ.get(
    "SUPABASE_ANON_KEY",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4Y2R6bHlpcmRvbmtpcGN5bXZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMTgxNzcsImV4cCI6MjA5NjU5NDE3N30.S70lUuSwgQBb05BFdcjRAP8F4x2ydeVppljuS6yKlQY",
)

# Canonical fixed-field order (mirrors ArticleContent._legacyFieldOrder).
LEGACY_FIELD_ORDER = [
    "definition",
    "epidemiology",
    "etiology",
    "pathophysiology",
    "clinicalFeatures",
    "redFlags",
    "approach",
    "diagnosis",
    "treatment",
    "contraindications",
    "dontMiss",
    "complications",
    "clinicalPearls",
    "ethiopianContext",
    "mnemonics",
    "examTraps",
]


def fetch_articles():
    url = f"{SUPABASE_URL}/rest/v1/articles?select=id,title,content&limit=1000"
    req = urllib.request.Request(url, headers={
        "apikey": ANON_KEY,
        "Authorization": f"Bearer {ANON_KEY}",
    })
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


def convert(content):
    """Return the new-shape JSON for an old-shape (or already-new) content."""
    if not isinstance(content, dict):
        content = {}
    if content.get("schemaVersion") is not None:
        # Already new shape — normalize but keep.
        return {
            "schemaVersion": content.get("schemaVersion", 2),
            "sections": content.get("sections", []),
        }
    sections = []
    for key in LEGACY_FIELD_ORDER:
        value = content.get(key)
        if isinstance(value, str) and value.strip():
            sections.append({"key": key, "body": value})
    return {"schemaVersion": 2, "sections": sections}


def main():
    try:
        rows = fetch_articles()
    except urllib.error.URLError as e:
        print(f"FETCH FAILED: {e}", file=sys.stderr)
        sys.exit(1)

    print(f"=== DRY RUN: {len(rows)} articles ===\n")
    changed = 0
    already_new = 0
    empty = 0
    for row in rows:
        aid = row.get("id")
        title = row.get("title")
        content = row.get("content")
        before = content if isinstance(content, dict) else {}
        after = convert(content)

        # Classify
        is_new_shape = isinstance(content, dict) and content.get("schemaVersion") is not None
        before_keys = sorted(k for k, v in before.items()
                             if isinstance(v, str) and v.strip()) if isinstance(before, dict) else []
        after_keys = [s["key"] for s in after["sections"]]

        if is_new_shape:
            already_new += 1
        elif not after_keys:
            empty += 1
        else:
            changed += 1

        print(f"### {title}  ({aid})")
        print(f"  shape: {'NEW (schemaVersion present)' if is_new_shape else 'OLD (fixed-field)'}")
        print(f"  before keys ({len(before_keys)}): {before_keys}")
        print(f"  after  keys ({len(after_keys)}):  {after_keys}")
        if before_keys != after_keys:
            print("  >> KEY ORDER/SET CHANGED vs legacy order")
        print(f"  after json: {json.dumps(after, ensure_ascii=False)}")
        print()

    print("=== SUMMARY ===")
    print(f"  total:        {len(rows)}")
    print(f"  would change: {changed}")
    print(f"  already new:  {already_new}")
    print(f"  empty (no sections): {empty}")
    print("\nNO WRITES PERFORMED (dry run).")


if __name__ == "__main__":
    main()
