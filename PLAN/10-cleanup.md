## BLOCK 10 — Verify the whole task and remove the plan

**Depends on:** BLOCK 9 committed
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
   flutter build apk --debug
   ```
   `flutter analyze` must print `No issues found!`. `flutter test` must print
   `All tests passed!` with a count of at least `183`. `flutter build apk --debug` must exit 0
   and print `✓ Built build/app/outputs/flutter-apk/app-debug.apk`; it takes roughly 60 seconds.
   If it instead fails with `IllegalArgumentException: 25.0.2`, the JDK 17 setting recorded in
   §6 was lost: that is a stop condition (§11 R12), not something to work around.
2. Confirm the localization sources are still in sync with the `.arb` files:
   ```
   flutter gen-l10n
   git status --porcelain lib/l10n
   ```
   `git status --porcelain lib/l10n` must print nothing. If it prints a modified file, that file
   was hand-edited instead of generated: that is a stop condition (§11 R12).
3. Check each `- [ ]` item in §2 by running the command or reading the file named in it. Every
   item must pass.
4. Only if steps 1–3 all passed:
   ```
   git rm -q PLAN.md
   git rm -rq PLAN
   ```

### Do not
- Do not delete the plan if any check failed — that is a stop condition (§11 R12).
- Do not fix a failure that §6 Baseline already recorded, namely the 8 pre-existing unformatted files.
- Do not run `dart format` across the repository in this block.
- Do not push, tag, or open a pull request.

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
git commit -m "Add the landscape expenses by category chart"
```
Do not run `git add -A` or `git commit -a` here.

### Next
Nothing. The plan is finished. Report to the human:

1. The branch name and the commit list from `git log --oneline a5c0c91..HEAD`.
2. Every gate result from step 1.
3. That two manual checks remain and cannot be automated here: rotating a real device or emulator between portrait and landscape in **both** the light and the dark theme, and swiping to change the month **while in landscape**.
