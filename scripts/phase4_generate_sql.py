#!/usr/bin/env python3
"""Generate scripts/phase4_write.sql from the live articles.

Reuses the EXACT convert() logic in phase4_dryrun.py (the one already
validated by the dry run). Emits one `update public.articles ...` statement
per article, wrapped in a single transaction. Does NOT execute anything.

Usage:
  python3 phase4_generate_sql.py
"""
import json
import os
import sys
import urllib.request
import urllib.error

# Import the validated convert() — same function the dry run uses.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from phase4_dryrun import fetch_articles, convert  # noqa: E402

OUT_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                         "phase4_write.sql")


def sql_escape(value):
    """Escape a string for embedding inside a single-quoted SQL literal."""
    return value.replace("'", "''")


def main():
    try:
        rows = fetch_articles()
    except urllib.error.URLError as e:
        print(f"FETCH FAILED: {e}", file=sys.stderr)
        sys.exit(1)

    statements = []
    for row in rows:
        aid = row.get("id")
        title = row.get("title")
        after = convert(row.get("content"))
        payload = json.dumps(after, ensure_ascii=False)
        # jsonb literal: single-quoted, single-quotes escaped, cast ::jsonb
        stmt = (
            f"-- {title}\n"
            f"update public.articles\n"
            f"set content = '{sql_escape(payload)}'::jsonb\n"
            f"where id = '{aid}';"
        )
        statements.append(stmt)

    header = (
        "-- Phase 4 WRITE: convert article content old-shape -> new shape.\n"
        "-- Generated from live data using the validated convert() in "
        "phase4_dryrun.py.\n"
        "-- Run in the Supabase SQL Editor (service role). All-or-nothing.\n"
        "begin;\n\n"
    )
    footer = "\ncommit;\n"

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write(header)
        f.write("\n\n".join(statements))
        f.write(footer)

    print(f"Wrote {len(statements)} statements to {OUT_PATH}")


if __name__ == "__main__":
    main()
