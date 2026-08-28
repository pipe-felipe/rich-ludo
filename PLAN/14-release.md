## BLOCK 14 — Verify everything, release v3.0.0 and remove the plan

**Depends on:** BLOCK 13 committed
**Touches:** `CHANGELOG.md` (MODIFY), `pubspec.yaml` (MODIFY), `README.md` (MODIFY), `PLAN.md` (deleted), `PLAN/` (deleted)

5 files: the three the release procedure names, plus the plan deleting itself. The release commit is
the last commit on the branch so the annotated tag lands on the branch tip.

### Goal
Every gate passes, `§2 Definition of done` is satisfied, the repository is at version `3.0.0+13`
with an annotated `v3.0.0` tag, and the plan is gone.

### Context to read first
1. §2 Definition of done — the list you are about to check.
2. §6 Baseline — the numbers you compare against.
3. `.claude/skills/generate-version/SKILL.md:14-23` — the project's release procedure. Steps 4 to 9 below are its steps 3 to 8 with the version already decided as `3.0.0`.
4. §5, the paragraph headed **One deliberate exception to §11 R4** — it grants this block, and only this block, permission to run `git tag`.
5. `CHANGELOG.md:1-24` — the `## [Unreleased]` heading and the shape of the `## [2.3.0]` section below it.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Run every gate in §5 that is not `NONE FOUND`, in the order CI runs them:
   ```
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --debug
   ```
   `flutter test` must report 334 passing, 0 failing. `flutter analyze` must print `No issues found!`.
   `flutter build apk --debug` replaces `flutter build apk --release` from CI, which §6 records as
   NOT RUN because the signing keystore is absent from this working tree.
2. Run the three e2e suites on the emulator:
   ```
   flutter test integration_test/edit_transaction_test.dart -d emulator-5554
   flutter test integration_test/custom_categories_test.dart -d emulator-5554
   flutter test integration_test/chart_orientation_test.dart -d emulator-5554
   ```
   They must report `+4`, `+4` and `+3` passing. Step 1's build plus this step is the smoke check:
   each run installs and drives the real app on the device.
3. Check each `- [ ]` item in §2 by running the command or reading the file named in it. Every item
   except the last two must pass now; the last two are satisfied by steps 4 to 9.
4. Run `date +%F` and keep its output. It is the release date used in step 5.
5. In `CHANGELOG.md`, leave the `## [Unreleased]` heading in place with nothing under it, and insert
   this section immediately below it, replacing `<date>` with the output of step 4:
   ```markdown
   ## [3.0.0] - <date>

   ### Added
   - Edit a transaction from the pencil button on its card: the dialog opens pre-filled with the stored type, category, amount, notes and `Repete` switch
   - Editing a recurring transaction asks which months the change covers — `Apenas este mês`, `Este mês e anteriores`, `Este mês e futuros`, `Todos os meses` — through the four-option dialog the delete flow already used
   - Turning the `Repete` switch off while editing a recurring transaction leaves `Este mês e anteriores` disabled, because a one-off row cannot cover past months
   - `UpdateTransactionUseCase` and `UpdateRecurringTransactionUseCase`, with `updateItem` and `updateRecurringItem` on `MainScreenViewModel`
   - `MonthYear` domain model carrying the month arithmetic the recurring rules need
   - Localization keys `recurringEditTitle` and `transactionEditTooltip` in Portuguese, English and Spanish
   - E2E test covering the four edit paths

   ### Changed
   - **Breaking**: `RecurringDeleteMode` is now `RecurringScope` in `lib/domain/model/recurring_scope.dart`, and `RecurringDeleteDialog` is now `RecurringScopeDialog`, taking its heading as a `title` parameter and an optional `disabledScopes` set
   - **Breaking**: `TransactionCard` and `TransactionList` require an `onEdit` callback, and `MainScreenViewModel` requires the two update use cases
   - `DeleteRecurringTransactionUseCase` uses `MonthYear` instead of its own private month helpers
   - `TransactionFormViewModel` holds the transaction being edited and exposes `startEditing`, `isEditing` and `buildEditedTransaction`
   - `AGENTS.md` states the no-duplication rule as a `## Reuse` section
   ```
6. In `pubspec.yaml`, change line 19 from `version: 2.3.0+12` to:
   ```yaml
   version: 3.0.0+13
   ```
7. In `README.md`, change the badge URL on line 4 from `https://img.shields.io/badge/version-2.3.0-green` to `https://img.shields.io/badge/version-3.0.0-green`.
8. Only if steps 1 to 3 all passed, remove the plan:
   ```
   git rm -q PLAN.md
   git rm -rq PLAN
   ```
9. Stage the three release files and commit, then tag:
   ```
   git add CHANGELOG.md pubspec.yaml README.md
   git commit -m "chore: release v3.0.0"
   git tag -a v3.0.0 -m "Release v3.0.0"
   ```
   Step 8 already staged both deletions, so they ride along in this commit.

### Do not
- Do not delete the plan if any check in steps 1 to 3 failed — that is a stop condition (§11 R12).
- Do not run `git add -A`, `git add .` or `git commit -a`: they would sweep in files this plan never touched.
- Do not push the branch and do not push the tag. `.claude/skills/generate-version/SKILL.md:23` leaves both to the human, and §11 R4 forbids both. The `git tag` in step 9 is the one scoped exception §5 grants to this block; nothing else in R4 is relaxed.
- Do not fix a failure that §6 Baseline already recorded.
- Do not run the formatter in this block; it touches no Dart file.
- Do not amend, squash or reorder any commit made by an earlier block.

### Verify
```
git status --porcelain
ls PLAN.md PLAN 2>&1
git tag --list v3.0.0
git log --oneline -1
grep -n "^version: 3.0.0+13" pubspec.yaml
```
Expected: `git status --porcelain` prints nothing, because step 9 committed everything and §6
recorded no pre-existing uncommitted paths; `ls` reports "No such file or directory" for both paths;
`git tag --list v3.0.0` prints `v3.0.0`; `git log --oneline -1` shows `chore: release v3.0.0`; the
`grep` prints one line.

A modified file left in `git status` means a gate rewrote it or a block left work behind: that is a
stop condition.

### If verification fails
Follow §11 R12. Restore the plan with `git checkout -- PLAN.md PLAN` if it was already removed.

### Commit
Step 9 already made the single commit for this block and created the tag. Make no further commit.

### Next
Nothing. The plan is finished. Report to the human: the branch name `feat/edit-transactions`, the
list of commits from `git log --oneline a69f001..HEAD`, the tag `v3.0.0`, every gate result from
steps 1 and 2, and this exact line:

```
Push when ready:  git push origin feat/edit-transactions --tags
```
