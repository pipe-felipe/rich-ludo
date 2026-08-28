## BLOCK 13 — Document the feature and tighten the reuse rule

**Depends on:** BLOCK 12 committed
**Touches:** `AGENTS.md` (MODIFY), `docs/project-map.md` (MODIFY), `docs/test-map.md` (MODIFY), `README.md` (MODIFY)

4 files: one documentation change per file, no code. Each is an independent edit and none can
break a gate.

### Goal
`AGENTS.md` states the no-duplication rule as a `## Reuse` section, and the three documents that
index the project list the edit feature and its tests.

### Context to read first
1. `AGENTS.md:25-36` — the `## Code Style` section and the two trailing `OBS:` lines that step 1 replaces.
2. `docs/project-map.md:22-38` — the `## Layer ownership` table and its column order.
3. `docs/test-map.md:3-18` — the `## Existing coverage` table and its column order.
4. `README.md:93-107` — the `## Features` list and its `- ✅ ` bullet style.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `AGENTS.md`, delete these two lines:
   ```
   OBS: Do not, ever, create a code duplication
   Make sure that there is no string or other kinda of variables that is created more than one time
   ```
   and put this section in their place, between `## Code Style` and `## Testing`:
   ```markdown
   ## Reuse

   Nothing in this repository exists twice. Before adding a constant, a widget, an enum, a helper
   or a localization key, find the one that already exists and use it.

   - **Search first**: run `grep -rn "<name>" lib/` before creating anything named after a concept
     the project already has.
   - **Shared behaviour**: when two flows need the same widget, enum or rule, they share one
     implementation. Do not copy a widget to change its title — pass the difference in as a
     parameter.
   - **Neutral names**: a type used by more than one flow is named for what it is, not for the flow
     that needed it first (`RecurringScope`, not `RecurringDeleteMode`), and lives in the layer both
     flows already depend on — `lib/domain/model/` for a shared domain type.
   - **Strings**: every user-facing string is one key present in all three of `lib/l10n/app_pt.arb`,
     `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`, read through `AppLocalizations`. Never write a
     user-facing literal in Dart, and never add a second key for text that already has one.
   - **Extract on the third**: two occurrences of a short rule may stay where they are; the third
     moves into a shared function. Do not build an abstraction for a single caller.
   ```
2. In `docs/project-map.md`, add these three rows at the end of the `## Layer ownership` table:
   ```markdown
   | Transaction edit rules | `lib/domain/usecase/update_transaction_usecase.dart`, `lib/domain/usecase/update_recurring_transaction_usecase.dart` | Writing an edit, and the four spans it can apply to on a recurring row |
   | Month arithmetic | `lib/domain/model/month_year.dart` | Stepping and ordering a (month, year) pair for the recurring rules |
   | Recurring scope UI | `lib/presentation/ui/widgets/recurring_scope_dialog.dart` | The four-option picker shared by the delete flow and the edit flow |
   ```
3. In `docs/test-map.md`, add these two rows at the end of the `## Existing coverage` table:
   ```markdown
   | Edit rules | `test/domain/usecase/update_transaction_usecase_test.dart`, `test/domain/usecase/update_recurring_transaction_usecase_test.dart`, `test/domain/model/month_year_test.dart` | Delegation, the four recurring spans with their collapse cases, and month arithmetic |
   | Edit UI | `test/presentation/ui/widgets/transaction_card_test.dart`, `test/presentation/ui/widgets/recurring_scope_dialog_test.dart`, `integration_test/edit_transaction_test.dart` | The pencil button, the disabled scope option, and the four end-to-end edit paths |
   ```
4. In `README.md`, add this bullet to the `## Features` list, immediately after the line `- ✅ Add transactions (income and expenses)`:
   ```markdown
   - ✅ Edit a transaction, choosing which months the change applies to when it repeats
   ```

### Do not
- Do not touch any file under `lib/`, `test/` or `integration_test/` in this block.
- Do not rewrite the parts of `AGENTS.md` outside the two `OBS:` lines, and do not change its `## Architecture`, `## Code Style`, `## Testing`, `## Quick Reference` or `## Commands` sections.
- Do not update the version badge in `README.md` — that is BLOCK 14.
- Do not add a new document under `docs/`. The three existing indexes carry this feature.

### Verify
Run from the repository root, in this order:
```
grep -n "^## Reuse" AGENTS.md
grep -c "OBS: Do not, ever, create a code duplication" AGENTS.md
grep -c "update_recurring_transaction_usecase" docs/project-map.md docs/test-map.md
grep -n "Edit a transaction, choosing which months" README.md
flutter test
```
Expected: the first prints one line; the second prints `0`; the third prints `1` for
`docs/project-map.md` and `1` for `docs/test-map.md`; the fourth prints one line; the fifth exits 0
and reports 334 passing tests, 0 failing, unchanged by this block.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 13's row in §12 Status to `DONE`.
2. Run:
   ```
   git add AGENTS.md docs/project-map.md docs/test-map.md README.md PLAN.md
   git commit -m "Document the transaction edit feature and state the reuse rule"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
