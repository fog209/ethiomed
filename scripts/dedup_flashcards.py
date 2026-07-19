#!/usr/bin/env python3
"""Collapse near-duplicate flashcards in scripts/apkg_flashcards.json.

A card is considered a duplicate when its (deck, front, back) tuple matches
an earlier card. Only the FIRST occurrence of each tuple is kept. This is a
pure, local operation: it does NOT touch Supabase, the Drift schema, or the
classification framework.

Output: scripts/apkg_flashcards_deduped.json (original left untouched).
"""
import json
import sys

SRC = "scripts/apkg_flashcards.json"
OUT = "scripts/apkg_flashcards_deduped.json"


def main() -> int:
    with open(SRC, "r", encoding="utf-8") as fh:
        cards = json.load(fh)

    seen = set()
    deduped = []
    dropped = 0
    for card in cards:
        key = (card.get("deck"), card.get("front"), card.get("back"))
        if key in seen:
            dropped += 1
            continue
        seen.add(key)
        deduped.append(card)

    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(deduped, fh, ensure_ascii=False, indent=2)

    print(f"input cards:     {len(cards)}")
    print(f"unique kept:     {len(deduped)}")
    print(f"duplicates dropped: {dropped}")
    print(f"wrote: {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
