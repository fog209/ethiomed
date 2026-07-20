# `flutter_markdown_plus` — Migration Feasibility Report

> Research-only. No code was written and `pubspec.yaml` / `pubspec.lock` were
> NOT modified for this report. Findings below were verified live on
> 2026-07-20 against `flutter_markdown_plus` 1.0.12 source and pub.dev.

## 1. Current state of the package (verified live)

| Field | Value |
| --- | --- |
| Package | `flutter_markdown_plus` |
| Version | `1.0.12` (published ~9 days before this report) |
| Publisher | `foresightmobile.com` (pub.dev **verified** publisher) |
| Licence | BSD-3-Clause |
| Pub points | 160 |
| Likes | 130 |
| Weekly / total downloads | ~426k total |
| Repo | https://github.com/foresightmobile/flutter_markdown_plus (94 open issues, actively triaged) |

It is the documented continuation of Google's discontinued `flutter_markdown`
(Google stopped shipping it; Foresight Mobile took over maintenance). The
readme explicitly states the package is *actively maintained* — bug reports are
triaged against the current release and patch fixes ship regularly
(e.g. 1.0.8, 1.0.10, 1.0.12). **It is not stale.** It depends on
`markdown ^7.3.1` (a major bump from the `^7.1.x`/`7.2.x` line used by the old
`flutter_markdown`), `meta ^1.16.0`, and `path ^1.9.1` — all already in the
Dart/Flutter ecosystem and compatible.

## 2. Does it fix our actual bug?

**Our bug:** `flutter_markdown` 0.7.7+1's `builder.dart` has a hardcoded
`else if (tag == 'table')` branch in `visitElementAfter` that **never consults
the `builders` map**, so our custom `ScrollableTableBuilder` (registered under
`'table'` in `article_detail_screen.dart`) is silently ignored.

**Verified against `flutter_markdown_plus` 1.0.12 `builder.dart` (live source):**
The same structural pattern persists. In `visitElementAfter`:

```dart
Widget child = builders[tag]?.visitElementAfterWithContext(...) ?? defaultChild();
...
} else if (tag == 'table') {
  if (styleSheet.tableColumnWidth is FixedColumnWidth ||
      styleSheet.tableColumnWidth is IntrinsicColumnWidth) {
    child = _ScrollControllerBuilder(builder: (... Scrollbar + SingleChildScrollView(horizontal) ...) ...);
  } else {
    child = _buildTable();
  }
}
```

There is **no `builders.containsKey('table')` guard** before this `else if`, so
a `builders['table']` entry is still overridden by the package's built-in table
renderer. **Our custom `ScrollableTableBuilder` would continue to be silently
ignored** — builder-dispatch parity was NOT restored for `table`.

**However, the real product need (a usably scrollable, styled table) is now
satisfied natively**, independent of the custom builder:

- **Built-in horizontal scroll for overflowing tables.** When
  `styleSheet.tableColumnWidth` is `FixedColumnWidth` or `IntrinsicColumnWidth`,
  the package wraps the table in a `SingleChildScrollView` with a `Scrollbar`
  (configurable `tableScrollbarThumbVisibility`). This is *exactly* what our
  `ScrollableTableBuilder` was doing by hand (wrap in horizontal
  `SingleChildScrollView`). Our `ScrollableTableBuilder` already uses
  `IntrinsicColumnWidth`, so the behaviour matches.
- **Rich `MarkdownStyleSheet` table styling** (new/retained props):
  `tableBorder` (now supports `borderRadius`, clipped via `ClipRRect`),
  `tableCellsPadding`, `tableCellsDecoration`, `tableHeadCellsPadding`,
  `tableHeadCellsDecoration`, `tableHeadAlign`, `tableColumnWidth`,
  `tableVerticalAlignment`, `tablePadding`. The header row gets
  `tableHeadCellsDecoration` automatically (`tr` length == 0 path), giving the
  zebra/sticky-header *look* without a custom builder.
- **What it does NOT give us:** a *pinned/sticky* header row that stays visible
  while the body scrolls vertically. The header just gets distinct
  decoration/alignment. "Sticky" (frozen) headers are not a built-in feature.
  Our old `ScrollableTableBuilder` did not do that either (it only added
  horizontal scroll + zebra striping), so nothing is lost there.

**Verdict: PARTIAL.** The custom-builder dispatch bug is *not* fixed — a
`'table'` builder is still ignored. But the underlying need (scrollable,
zebra/styled tables) is now achievable with pure `MarkdownStyleSheet`
configuration, making the custom builder unnecessary. So migration can retire
`ScrollableTableBuilder` and rely on native scroll + styling.

## 3. Migration surface (grep of `flutter_markdown` usage)

Three files reference `package:flutter_markdown/flutter_markdown.dart`:

| File | Usage | Migration note |
| --- | --- | --- |
| `lib/features/articles/presentation/article_markdown_helpers.dart` | Imports `flutter_markdown`; defines `ScrollableTableBuilder` (+ `MedicalTermLinkBuilder`) | Swap import to `flutter_markdown_plus`. `MarkdownElementBuilder`, `visitElementAfterWithContext`, and `md` types are API-compatible. `ScrollableTableBuilder` (table) becomes redundant — see §2. |
| `lib/features/articles/presentation/article_detail_screen.dart` | Imports `flutter_markdown`; registers `builders: {'table': ScrollableTableBuilder(...)}` (line ~926) | Swap import. Remove `'table'` builder registration; configure `MarkdownStyleSheet` for scroll/styling instead. |
| `test/medical_term_link_builder_test.dart` | Imports `flutter_markdown`; tests `MedicalTermLinkBuilder` | Swap import. `MedicalTermLinkBuilder` is inline-tag (`a`)-based, which the package *does* dispatch correctly. |

**API diff beyond a plain package-name swap:**

1. **Import path** changes `flutter_markdown` → `flutter_markdown_plus`
   (and constructor arg order of `Markdown`/`MarkdownBody` is unchanged).
2. **Custom `table` builder must be removed**, not just renamed — it cannot
   work. Replace with `MarkdownStyleSheet` table props (`tableColumnWidth`,
   `tableCellsPadding`, `tableCellsDecoration`, `tableHeadCells*`, `tableBorder`
   with `borderRadius`, `tablePadding`). This is a *logic* change, not a
   find-and-replace.
3. **`markdown` dependency bump:** the package requires `markdown ^7.3.1`. The
   app's other `markdown` usage (in `article_markdown_helpers.dart` it imports
   `package:markdown/markdown.dart` as `md`) must remain compatible with 7.3.x.
   Our usage (`md.Element`, `md.Node`, `element.tag`, `textContent`,
   `attributes`) is stable across 7.x — low risk, but should be smoke-tested.
4. Everything else (`MarkdownElementBuilder`, `MarkdownBody`, `onTapLink`,
   `extensionSet`, `MarkdownStyleSheet.fromTheme`) is name-compatible.

## 4. Open GitHub issues relevant to tables / custom builders

Searched `is:issue table OR builder in:title` (94 open issues total):

- **#73 / #48** "Allow aligning table cell content" — Open.
- **#59** "Crash if using > [!NOTE] syntax because custom block builders do not
  work" — Open (confirms custom-block builder gaps still exist).
- **#57 / #46** "Custom Builder for 'hr' Tag Not Invoked" — Open (confirms
  custom-builder dispatch is still partially broken for some tags).
- **#78** "give access to children" — Open.
- **#87 / #80 / #53** — various custom-builder / inline-syntax requests — Open.
- **#132** "MarkdownElementBuilder replaces only first child..." — Closed/fixed
  (Jul 6 2026); a real builder-dispatch correctness fix landed.

No *table-specific* builder-dispatch fix is open or merged. The open issues
reinforce §2: custom builders (incl. `table`) are still not reliably dispatched.

## 5. Risks

- **R1 (medium):** Removing `ScrollableTableBuilder` changes table rendering
  from our hand-built `Table` (with `Colors.black12` borders + zebra containers)
  to the package's `Table` driven by `MarkdownStyleSheet`. Visual regression is
  possible; needs a screenshot diff on a real article with a wide table.
- **R2 (low):** `markdown` package bump to `^7.3.1` could shift transitive
  behaviour; must run full `flutter test` + `flutter analyze`.
- **R3 (low):** No *pinned/sticky* header. If the owner later wants a frozen
  header row, this package won't provide it without a custom (non-`table`)
  widget wrapper — out of scope for this report.
- **R4 (low/operational):** It is a community fork, not first-party Google. Mit
  by pinning an exact version (`^1.0.12`) and watching releases.

## 6. Recommendation

**Migrate.** `flutter_markdown_plus` is actively maintained (verified
publisher, frequent patch releases, 160 pub points, 426k downloads) and is the
only maintained continuation of the discontinued original. It does **not** fix
the custom-`table`-builder dispatch bug — a `builders['table']` entry is still
silently ignored — but that no longer matters: the package now renders
overflowing tables with built-in horizontal `SingleChildScrollView` + `Scrollbar`
(when `tableColumnWidth` is `FixedColumnWidth`/`IntrinsicColumnWidth`) and
exposes rich `MarkdownStyleSheet` table styling (`tableBorder` with `borderRadius`,
head/body cell padding & decoration, alignment). That natively covers the real
product need our `ScrollableTableBuilder` was working around, so we can delete
the custom `table` builder and configure styling declaratively. The only
non-trivial migration step is swapping the import path in the three listed files
and replacing the `'table'` builder registration with `MarkdownStyleSheet`
configuration; the inline `MedicalTermLinkBuilder` (on the `a` tag, which the
package dispatches correctly) carries over unchanged. De-risk with a screenshot
diff on a wide table and a full test/analyze run.
