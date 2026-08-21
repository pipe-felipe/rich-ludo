## BLOCK 1 — Add the three chart localization keys

**Depends on:** none
**Touches:** `lib/l10n/app_pt.arb` (MODIFY), `lib/l10n/app_en.arb` (MODIFY), `lib/l10n/app_es.arb` (MODIFY), `lib/l10n/app_localizations.dart` (REGENERATED), `lib/l10n/app_localizations_pt.dart` (REGENERATED), `lib/l10n/app_localizations_en.dart` (REGENERATED), `lib/l10n/app_localizations_es.dart` (REGENERATED)

7 files: 3 hand-edited `.arb` files plus 4 files that `flutter gen-l10n` rewrites from them. The
4 generated files are versioned in this repository and must be committed together with the
`.arb` files.

### Goal
`AppLocalizations` exposes `chartTitle`, `categoryUncategorized` and `chartTotalExpense` in
Portuguese, English and Spanish.

### Context to read first
1. `lib/l10n/app_pt.arb` — the whole file (55 lines). It is the template declared in `l10n.yaml:2`. Keys are flat `"key": "value"` pairs, two-space indented, no `@key` metadata anywhere.
2. `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` — the same key order as the template, with translated values.
3. `l10n.yaml` — 3 lines; it makes `flutter gen-l10n` read `lib/l10n` and write `app_localizations.dart`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/l10n/app_pt.arb`, replace the line `  "december": "Dezembro"` with:
   ```json
     "december": "Dezembro",
     "chartTitle": "Despesas por categoria",
     "categoryUncategorized": "Sem categoria",
     "chartTotalExpense": "Total de despesas"
   ```
2. In `lib/l10n/app_en.arb`, replace the line `  "december": "December"` with:
   ```json
     "december": "December",
     "chartTitle": "Expenses by category",
     "categoryUncategorized": "Uncategorized",
     "chartTotalExpense": "Total expenses"
   ```
3. In `lib/l10n/app_es.arb`, replace the line `  "december": "Diciembre"` with:
   ```json
     "december": "Diciembre",
     "chartTitle": "Gastos por categoría",
     "categoryUncategorized": "Sin categoría",
     "chartTotalExpense": "Total de gastos"
   ```
4. Regenerate the localization sources:
   ```
   flutter gen-l10n
   ```
   It prints `Because l10n.yaml exists, the options defined there will be used instead.` and
   exits 0. That line is expected output, not an error.

### Do not
- Do not add `@key` metadata blocks, placeholders, or descriptions — no key in these files has any.
- Do not reorder or retranslate existing keys.
- Do not hand-edit any `lib/l10n/app_localizations*.dart` file; step 4 writes them.
- Do not touch `l10n.yaml` or `pubspec.yaml`.

### Verify
Run from the repository root, in this order:
```
grep -c "chartTitle\|categoryUncategorized\|chartTotalExpense" lib/l10n/app_pt.arb lib/l10n/app_en.arb lib/l10n/app_es.arb
grep -c "get chartTitle\|get categoryUncategorized\|get chartTotalExpense" lib/l10n/app_localizations.dart lib/l10n/app_localizations_pt.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart
flutter analyze
```
Expected: the first command prints `3` for each of the three `.arb` files; the second prints `3`
for each of the four Dart files; `flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 1's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/l10n/app_pt.arb lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_pt.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart PLAN.md
   git commit -m "Add chart localization keys"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
