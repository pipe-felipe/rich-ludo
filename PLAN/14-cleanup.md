## BLOCK 14 — Verify the whole task and remove the plan

**Depends on:** BLOCK 13 committed
**Touches:** `PLAN.md` (deleted), `PLAN/` (deleted)

### Goal
Prove the task is complete against §2, then remove the plan from the repository.

### Context to read first
1. §2 Definition of done — the list you are about to check.
2. §6 Baseline — the numbers you compare against.

### Steps
1. Run every gate in §5 that is not `NONE FOUND`, in the order CI runs them:
   ```
   flutter pub get
   flutter analyze
   flutter test
   flutter build apk --release
   ```
   `flutter analyze` must print `No issues found!`. `flutter test` must print `All tests passed!`
   with 299 tests. `flutter build apk --release` must exit 0, print
   `Built build/app/outputs/flutter-apk/app-release.apk`, and print a line starting with
   `Font asset "MaterialIcons-Regular.otf" was tree-shaken` — that line is the proof that the
   24 icons of `customCategoryIcons` are still resolvable at compile time (§9, first bar).
2. Do not try to start the app. §5 records that `flutter run` needs an Android or iOS device, and
   §6 records that none is attached, so there is nothing to start here. The release build in
   step 1 is the compile proof. Hand the run command to the human in **Next** item 4 instead.
3. Check each `- [ ]` item in §2 by running the command or reading the file named in it. The two
   items that are commands are:
   ```
   grep -c 'customCategories:' lib/presentation/ui/screens/main_screen.dart
   grep -n 'databaseVersion = 3' lib/config/database_config.dart
   ```
   The first must print `4`. The second must print one line. Every other item names a test file
   that step 1 already ran, or a file to read.
4. Confirm no production call site still relies on the `const []` default of the three resolution
   helpers:
   ```
   grep -rn 'getCategoryIcon(\|getExpenseCategoryColor(\|getExpenseCategoryLabel(' lib/
   ```
   Every hit outside `lib/presentation/ui/utils/` must pass `customCategories:`. There are
   exactly 4 such hits: one in `lib/presentation/ui/widgets/transaction_card.dart` and three in
   `lib/presentation/ui/widgets/chart/pie_chart.dart`. A hit without `customCategories:` is a
   stop condition.
5. Only if steps 1-4 all passed:
   ```
   git rm -q PLAN.md
   git rm -rq PLAN 2>/dev/null || true
   ```
6. Do not run `dart format` in this block; it would rewrite files outside this block's Touches
   and make the check in **Verify** fail.

### Do not
- Do not delete the plan if any check failed — that is a stop condition (§11 R12).
- Do not fix a failure that §6 Baseline already recorded. In particular, `dart format --output=none --set-exit-if-changed` is not a gate here and its 7 pre-existing files are not yours.
- Do not push, tag, or open a pull request.
- Do not bump `version:` in `pubspec.yaml` or create a release section in `CHANGELOG.md` (§3).

### Verify
```
git status --porcelain
ls PLAN.md PLAN 2>&1
```
Expected: `git status --porcelain` lists staged deletions (lines starting with `D `) for
`PLAN.md` and every `PLAN/` file, and nothing else — §6 recorded no pre-existing uncommitted
paths; `ls` reports "No such file or directory" for both paths.

A modified file that is neither of those means a gate rewrote it (§5 `write-only`) or a block
left work behind: that is a stop condition.

### If verification fails
Follow §11 R12. Restore the plan with `git checkout -- PLAN.md PLAN` if it was already removed.

### Commit
`git rm` already staged both deletions, so nothing needs adding:
```
git commit -m "Complete the user-created categories feature and remove PLAN.md"
```
Do not run `git add -A` or `git commit -a` here.

### Next
Nothing. The plan is finished. Report to the human:

1. The branch name, `feat/custom-categories`.
2. The list of commits: `git log --oneline 588d5f4..HEAD`.
3. Every gate result from step 1, with the test count and the tree-shaking line.
4. That the app was not started and the E2E suite was not run, and the exact commands the human
   can run on an Android or iOS device: `flutter run`, and
   `flutter test integration_test/chart_orientation_test.dart -d <device>`.
5. That nothing was pushed and no version was bumped, so the release is theirs to cut with the
   `generate-version` skill.
