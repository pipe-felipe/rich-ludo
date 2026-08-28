## BLOCK 4 — Add the edit localization keys

**Depends on:** BLOCK 3 committed
**Touches:** `lib/l10n/app_pt.arb` (MODIFY), `lib/l10n/app_en.arb` (MODIFY), `lib/l10n/app_es.arb` (MODIFY)

Step 4 regenerates the four `lib/l10n/app_localizations*.dart` files, which are tracked in git and
are committed with this block. They are tool output, not hand-written code: the three `.arb` files
above are the only ones edited by hand.

### Goal
`AppLocalizations` exposes `recurringEditTitle` and `transactionEditTooltip` in Portuguese, English
and Spanish.

### Context to read first
1. `lib/l10n/app_pt.arb:36-40` — the `recurringDelete*` block the two new keys sit next to, and the file's two-space indentation and key order.
2. `lib/l10n/app_en.arb:36-40` and `lib/l10n/app_es.arb:36-40` — the same block in the other two locales.
3. `l10n.yaml` — the whole file (3 lines): `app_pt.arb` is the template, the output is `app_localizations.dart` in `lib/l10n`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/l10n/app_pt.arb`, immediately after the line `  "recurringDeleteAll": "Todos os meses",`, insert:
   ```json
     "recurringEditTitle": "Editar recorrente",
     "transactionEditTooltip": "Editar transação",
   ```
2. In `lib/l10n/app_en.arb`, immediately after the line `  "recurringDeleteAll": "All months",`, insert:
   ```json
     "recurringEditTitle": "Edit recurring",
     "transactionEditTooltip": "Edit transaction",
   ```
3. In `lib/l10n/app_es.arb`, immediately after the line `  "recurringDeleteAll": "Todos los meses",`, insert:
   ```json
     "recurringEditTitle": "Editar recurrente",
     "transactionEditTooltip": "Editar transacción",
   ```
4. Regenerate the Dart localizations with the §5 write-only codegen command:
   ```
   flutter gen-l10n
   ```

### Do not
- Do not edit `lib/l10n/app_localizations.dart`, `app_localizations_pt.dart`, `app_localizations_en.dart` or `app_localizations_es.dart` by hand. Step 4 writes them.
- Do not add a third key for the edit dialog's submit button. The dialog keeps `formSubmitButton`, which already exists in all three locales; §9 forbids a second key for text that already exists.
- Do not reword or reorder any existing key.

### Verify
Run from the repository root, in this order:
```
grep -c "recurringEditTitle\|transactionEditTooltip" lib/l10n/app_pt.arb lib/l10n/app_en.arb lib/l10n/app_es.arb
grep -c "String get recurringEditTitle\|String get transactionEditTooltip" lib/l10n/app_localizations.dart lib/l10n/app_localizations_pt.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart
flutter analyze
```
Expected: the first command prints `2` for each of the three `.arb` paths; the second prints `2`
for each of the four Dart paths; the third exits 0 and prints `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only the three `.arb` files listed in **Touches**, then re-run `flutter gen-l10n`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 4's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/l10n/app_pt.arb lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_localizations.dart lib/l10n/app_localizations_pt.dart lib/l10n/app_localizations_en.dart lib/l10n/app_localizations_es.dart PLAN.md
   git commit -m "Add the transaction edit localization keys"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
