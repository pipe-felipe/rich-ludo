# PLAN — Tap the transaction card to edit it

Machine-readable execution plan. Audience: the LLM executing it. Follow it literally.
Progress lives in §12 Status. Start with §11.

## 1. Task

Today a transaction card shows a pencil `IconButton` that opens the edit dialog. Remove
that button and make the card itself the edit affordance: tapping anywhere on the card
body calls the existing `onEdit` callback, which opens the same
`TransactionDialog` editing flow. The trash button and its `onDelete` callback stay
unchanged. Decided: the tap target is an `InkWell` inside the `Card` (keeps the Material
ripple), and the localized string `transactionEditTooltip` is reused as a `Semantics`
label on the card so screen readers still announce "Editar transação" — no l10n file
changes, no new key, the dialog logic, `transaction_list.dart` and `main_screen.dart`
plumbing are untouched.

## 2. Definition of done

Every item is checkable by running a named command or reading a named file.

- [ ] `grep -rn "Icons.edit" lib/` prints nothing (the pencil icon is gone from production code).
- [ ] Test `should show the delete button only` passes in `test/presentation/ui/widgets/transaction_card_test.dart`: `find.byIcon(Icons.edit)` matches nothing, `find.byIcon(Icons.delete)` matches one widget.
- [ ] Test `should call onEdit when the card body is tapped` passes: tapping the card body calls `onEdit` once and `onDelete` zero times.
- [ ] Test `should call onDelete when the trash can is tapped` still passes unchanged.
- [ ] `flutter test` prints `All tests passed!` with 335 tests (the §6 Baseline count; no test is added or removed).
- [ ] `flutter analyze` prints `No issues found!`.
- [ ] `flutter build apk --debug` prints `✓ Built build/app/outputs/flutter-apk/app-debug.apk`.
- [ ] All gates in §5 pass at least as well as §6 Baseline.
- [ ] `PLAN.md` no longer exists.

## 3. Out of scope

- The delete button, its icon, position, and `onDelete` flow.
- `lib/presentation/ui/widgets/transaction_list.dart` and `lib/presentation/ui/screens/main_screen.dart` — their `onEdit`/`onDelete` plumbing already works and stays as-is.
- `lib/l10n/` (`.arb` files and generated `app_localizations*.dart`) — the key `transactionEditTooltip` is reused, not renamed or removed.
- `TransactionDialog`, `TransactionFormViewModel`, and the recurring-scope edit rules.
- `CHANGELOG.md` — the `generate-version` skill owns it at release time.
- Reformatting the 5 files listed in §6 (pre-existing unformatted files).

## 4. Branch

Branch: `feat/tap-card-to-edit`
Base: `main` at `de24ea85b45ebf44a273ae15c8fb435bd702d6c5`
Created for this task.

All work happens on this branch. See §11 R4.

## 5. Project facts

Every command below was read from the file cited. A row marked `NONE FOUND` must never be run.
A row marked `write-only` rewrites files: it belongs in a block's Steps, never in a **Verify**
list and never in the final block's gate list.

| Fact | Value | Source |
|---|---|---|
| Package manager | Flutter SDK / pub (`pubspec.lock`) | `pubspec.lock` |
| Install | `flutter pub get` | `.github/workflows/build-release.yml` (step "Get dependencies") |
| Unit tests (all) | `flutter test` | `AGENTS.md` Commands |
| Unit tests (one file) | `flutter test <path>` | `AGENTS.md` Commands |
| Lint | `flutter analyze` | `AGENTS.md` Commands |
| Format check | `dart format --output=none --set-exit-if-changed lib test` — fails at baseline, see §6; not a CI gate, never used as a gate in this plan | `docs/test-map.md:44` |
| Format write (`write-only`) | `dart format <paths>` | `docs/test-map.md:44` |
| Build | `flutter build apk --debug` | `docs/project-map.md:53` |
| E2e | `flutter test integration_test/edit_transaction_test.dart -d <device>` — needs a connected Android device/emulator and calls `deleteAll()` on that device's database | `integration_test/edit_transaction_test.dart:16`, `:24` |
| Run the app | NONE FOUND | — |
| CI gates, in order | `flutter test`, then `flutter build apk --release` (release build is keystore-gated; the local stand-in is `flutter build apk --debug`) | `.github/workflows/build-release.yml` |
| Commit style | one short line, sentence case, imperative, no scope prefix | `git log` |
| Commit examples | "Fix Color and Add Horizontal Gesture (#2)" / "UI polishment and backup (#1)" | `git log` |

## 6. Baseline — recorded 2026-09-02

| Gate | Command | Result |
|---|---|---|
| Unit | `flutter test` | 335 tests, `All tests passed!` |
| Lint | `flutter analyze` | `No issues found!` |
| Build | `flutter build apk --debug` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` (~29 s) |
| E2e | `flutter test integration_test/edit_transaction_test.dart -d <device>` | NOT RUN — no Android device/emulator attached; the test wipes the target's app database |
| Format check | `dart format --output=none --set-exit-if-changed lib test` | FAILS pre-existing on 5 files: `lib/data/services/transaction_local_service.dart`, `lib/domain/usecase/get_non_recurring_balance_usecase.dart`, `test/data/repository/transaction_repository_impl_test.dart`, `test/fakes/fake_transaction_repository.dart`, `test/fakes/fake_transaction_service.dart` |

Known pre-existing failures: the 5 unformatted files listed in the Format check row.
A failure listed here is not caused by this plan: do not fix it, do not let it block a block (§11 R12).

Pre-existing uncommitted paths: None.
These paths are not yours: never stage them, never revert them. The final block expects to see
them in `git status`.

## 7. Architecture and style rules that bind this task

1. Every user-facing string goes through `AppLocalizations`; reuse the existing key
   `transactionEditTooltip` (`lib/l10n/app_pt.arb:42`) as the card's `Semantics` label.
   Do not inline a literal and do not add a second key for this text — `AGENTS.md` Reuse/Strings.
2. Widgets used only in the same file are private (`_NameWidget`) — `AGENTS.md` Code Style;
   `transaction_card.dart` already follows this with `_CategoryIcon`, `_TransactionDetails`, `_AmountText`.
3. Code, comments and tests in English; tests named `should <X> when <Y>` — `AGENTS.md` Testing.
4. Unit tests ship in the same block as the code they cover, in `test/` mirroring the `lib/` path — `AGENTS.md` Testing.
5. Do not use `lib/data/local/dao/transaction_dao.dart` for anything — `docs/project-map.md:44` (non-authoritative legacy path).

## 8. Security invariants

No security documentation found in this repository. Baseline invariants apply: never log or
commit secrets; never interpolate untrusted input into SQL, HTML, shell, or file paths;
never remove or bypass an existing authentication or authorization check; never widen a CORS,
cookie, or permission setting.

## 9. Quality bars

Violating any of these is a defect even when the tests pass.

- Reuse the existing `onEdit` parameter of `TransactionCard` (`lib/presentation/ui/widgets/transaction_card.dart:14`); do not add a second callback such as `onCardTap` for the same behaviour.
- Do not edit `transaction_list.dart` or `main_screen.dart`; the `onEdit` plumbing through them already exists.
- Do not modify anything under `lib/l10n/`; the key `transactionEditTooltip` keeps its name and the generated files stay untouched.
- Do not wrap the `Card` in a `GestureDetector`; use the `InkWell` inside the `Card` as §1 states, so the Material ripple stays visible.
- Do not add a `Tooltip` widget around the card; the `Semantics` label announces the same text without the long-press side effect.
- Do not write tests that assert on `Semantics` nodes; the three behaviors (pencil gone, tap card → `onEdit`, trash → `onDelete`) are the coverage.
- No new dependency, script, config file, or generated file.
- When "avoid duplication" and "avoid over-engineering" conflict, choose the smaller diff: duplicate once, extract on the third occurrence.

## 10. Test obligations

| Kind | Required | Why | Location | Command |
|---|---|---|---|---|
| Unit (widget) | yes | the card's tap behaviour changed | `test/presentation/ui/widgets/transaction_card_test.dart` (existing file, tests rewritten in place) | `flutter test test/presentation/ui/widgets/transaction_card_test.dart` |
| E2e (integration) | update the existing file only | its helper taps `Icons.edit`, which this task removes; running it needs an Android device that wipes its own data, and CI does not run it — the recorded decision is: update + `flutter analyze`, do not execute | `integration_test/edit_transaction_test.dart` | `flutter test integration_test/edit_transaction_test.dart -d <device>` (NOT RUN in this plan) |

Follow the existing test style at `test/presentation/ui/widgets/transaction_card_test.dart`.

## 11. EXECUTOR CONTRACT

You are executing a plan, not designing one. Every decision in it has already been made and
approved. Your job is to carry out one block at a time, exactly as written, and to stop when
reality disagrees with the plan.

**R1 — One block at a time.** Read §1 through §12 first: that is your whole brief. Then open
§12 Status, find the first row whose status is `TODO`, and read that one block. Read no other
block. Do not read ahead, do not batch two blocks, do not reorder.

**R2 — Do not redesign.** If a step looks suboptimal, do it anyway. If a step looks *wrong*
or impossible, stop (R12). Never substitute your own approach.

**R3 — Touch only the listed files.** A block's **Touches** list is exhaustive. If the change
seems to require editing any other file, stop (R12).

**R4 — One branch.** Before starting a block, run `git branch --show-current`. If the output
is not `feat/tap-card-to-edit`, stop (R12). Never leave, hide or rewrite the branch's work: no
`git checkout feat/tap-card-to-edit`, `git switch`, `git merge`, `git rebase`, `git reset`, `git stash`,
`git commit --amend`, `git push`, `git tag`, and no command that opens a pull request.
Never create a second branch.
Restoring a file with `git checkout -- <path>` is allowed; that is the only `git checkout`
you may run.

**R5 — Always verify.** Run the block's **Verify** commands exactly as written, from the
repository root, all of them, in the given order. A block is never done because the code
"looks right". Never edit a Verify command to make it easier.

**R6 — Never weaken a check.** Do not delete, rename, skip, `.skip`, `xit`, `@Ignore`, comment
out, or loosen the assertions of any test. Do not add `eslint-disable`, `@ts-ignore`,
`@ts-expect-error`, `as any`, `# type: ignore`, `# noqa`, or a cast to silence an error. Do not
lower a coverage threshold, relax a lint rule, or edit CI configuration. If a check fails,
either the code is wrong or the plan is wrong — fix the code, or stop (R12).

**R7 — Add nothing unrequested.** No new dependency, script, config file, environment
variable, feature flag, generated file, or lockfile change unless a step says so explicitly.

**R8 — Match the surrounding style.** Write code in the style of the file you are editing and
of the sibling file named in **Context to read first**: same naming, same import order, same
export style, same error handling, same test structure, same language for comments and
user-facing strings. When in doubt, copy the sibling.

**R9 — Keep it minimal.** Implement exactly what the steps say and nothing more. No extra
abstraction layer, no interface with one implementation, no "while I'm here" refactor, no
defensive branches for cases the steps do not mention, no new utility for a single caller, no
commented-out code, no `TODO` comments, no leftover `console.log` / `print` / debugger.

**R10 — Security is not optional.** Re-read §8 Security invariants before writing any code
that touches authentication, authorization, input parsing, output rendering, secrets,
headers, cookies, file paths, uploads, or external calls. After such a block, confirm each
listed invariant still holds before committing.

**R11 — Commit every block.** When Verify passes: (1) set the block's row in §12 Status to
`DONE`; (2) `git add` the exact paths from **Touches** plus `PLAN.md`; (3) commit with the
exact message given in the block. One commit per block, no more, no fewer. Never `git add -A`,
`git add .`, or `git commit -a`: they sweep in files this plan never touched. The last block
is the one exception to (1) — it deletes `PLAN.md` instead of marking a row `DONE`.

**R12 — Stop conditions.** When any of the following happens: set that block's row in §12 to
`BLOCKED`, append the failing command and its **exact, unedited output** under `## Blocked`
at the end of `PLAN.md`, commit only `PLAN.md` with the message `Block <N> blocked`, and stop.
Report to the human. Do not proceed to another block. Leave the block's half-finished changes
in the working tree: do not revert them and do not commit them — the human reads them.

- Verify still fails after 2 fix attempts.
- A step names a file, symbol, command, or option that does not exist.
- Two steps contradict each other, or a step can be read in more than one way.
- The change would require touching a file outside **Touches**.
- A gate fails that §6 Baseline recorded as passing, and your change does not explain it.
- Following a step would violate §7 Architecture, §8 Security, or §9 Quality bars.

A failure that §6 Baseline already recorded is **not yours**: do not fix it, do not let it
block you, and note in the block that you saw the known-failing gate.

**R13 — The plan deletes itself last.** Never delete or shorten `PLAN.md` or `PLAN/` except in
the final block, and only after every gate in it has passed.

## 12. Status

Single source of truth for progress. The next block is the first row marked `TODO`.

The **Where** column is a literal search string: the block's own heading inside §13, or the
path of its file. Searching for it must land on the block.

| # | Block | Where | Status |
|---|---|---|---|
| 1 | Make the card tappable and rewrite its widget tests | §13, heading `BLOCK 1` | TODO |
| 2 | Point the edit e2e helper at the card and update the test map | §13, heading `BLOCK 2` | TODO |
| 3 | Verify the whole task and remove the plan | §13, heading `BLOCK 3` | TODO |

Statuses: `TODO` → `DONE`, or `BLOCKED` (see §11 R12).

## 13. Blocks

## BLOCK 1 — Make the card tappable and rewrite its widget tests

**Depends on:** none
**Touches:** `lib/presentation/ui/widgets/transaction_card.dart` (MODIFY), `test/presentation/ui/widgets/transaction_card_test.dart` (MODIFY)

### Goal

Tapping the card body calls `onEdit` once, the pencil `IconButton` is gone, and the trash button still calls `onDelete`.

### Context to read first

1. `lib/presentation/ui/widgets/transaction_card.dart` — the whole file (160 lines): the `build` method (lines 28–82) is the only part that changes; `_CategoryIcon`, `_TransactionDetails`, `_AmountText` (lines 85–160) stay byte-identical.
2. `test/presentation/ui/widgets/transaction_card_test.dart` — the whole file (108 lines): the test style to keep — `pumpCard` helper (lines 22–39), `cardTransaction` factory (lines 10–20), counters for callbacks.
3. `lib/presentation/ui/widgets/transaction_list.dart` — read lines 28–33 only, to confirm `onEdit` is already passed to `TransactionCard` and needs no change here.

Read exactly these. Do not open other files unless a step below names one.

### Steps

1. In `lib/presentation/ui/widgets/transaction_card.dart`, replace the entire `return Card(...);` statement of `build` (lines 36–82) with:
   ```dart
   return Card(
     color: backgroundColor,
     margin: const EdgeInsets.symmetric(vertical: 4),
     child: Semantics(
       label: AppLocalizations.of(context)!.transactionEditTooltip,
       button: true,
       child: InkWell(
         onTap: onEdit,
         borderRadius: BorderRadius.circular(12),
         child: Padding(
           padding: const EdgeInsets.all(14),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _CategoryIcon(
                 category: item.category,
                 customCategories: customCategories,
                 isIncome: _isIncome,
                 iconColor: iconColor,
               ),
               const SizedBox(width: 12),
               _TransactionDetails(
                 description: item.description,
                 humanDate: item.humanDate,
               ),
               Flexible(
                 child: FittedBox(
                   fit: BoxFit.scaleDown,
                   child: _AmountText(
                     amountCents: item.amountCents,
                     isIncome: _isIncome,
                   ),
                 ),
               ),
               IconButton(
                 onPressed: onDelete,
                 visualDensity: VisualDensity.compact,
                 icon: Icon(Icons.delete, color: AppTheme.thrashCan(context)),
               ),
             ],
           ),
         ),
       ),
     ),
   );
   ```
   This deletes the pencil `IconButton` (old lines 64–72) and adds `Semantics` + `InkWell`. Every import at the top of the file stays: `AppLocalizations` is still used by the `Semantics` label.
2. In `test/presentation/ui/widgets/transaction_card_test.dart`, replace the whole test `testWidgets('should show one edit button and one delete button', ...)` (lines 42–49) with:
   ```dart
   testWidgets('should show the delete button only', (tester) async {
     await pumpCard(tester, cardTransaction(), onEdit: () {}, onDelete: () {});

     expect(find.byIcon(Icons.edit), findsNothing);
     expect(find.byIcon(Icons.delete), findsOneWidget);
   });
   ```
3. In the same test file, replace the whole test `testWidgets('should call onEdit when the pencil is tapped', ...)` (lines 51–66) with:
   ```dart
   testWidgets('should call onEdit when the card body is tapped', (tester) async {
     var editCount = 0;
     var deleteCount = 0;
     await pumpCard(
       tester,
       cardTransaction(),
       onEdit: () => editCount++,
       onDelete: () => deleteCount++,
     );

     await tester.tap(find.byType(TransactionCard));
     await tester.pump();

     expect(editCount, equals(1));
     expect(deleteCount, equals(0));
   });
   ```
   `TransactionCard` is already imported on line 7 of the test file; add no import.
4. Change nothing else in the test file: `should call onDelete when the trash can is tapped` (lines 68–85) and `should lay the row out without overflowing a phone width` (lines 87–106) stay as they are.
5. Run the §5 write-only formatter on the Touches paths only:
   ```
   dart format lib/presentation/ui/widgets/transaction_card.dart test/presentation/ui/widgets/transaction_card_test.dart
   ```

### Do not

- Do not add a new callback parameter (for example `onCardTap`) to `TransactionCard`; the `InkWell` uses the existing `onEdit`.
- Do not modify `transaction_list.dart`, `main_screen.dart`, or anything under `lib/l10n/` — they are not in Touches.
- Do not add assertions on `Semantics` nodes to the tests (§9).
- Do not replace `InkWell` with `GestureDetector`, and do not wrap the card in a `Tooltip` (§9).

### Verify

Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/transaction_card_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `4 passed` (the file keeps exactly 4 tests);
the second prints `No issues found!`.

### If verification fails

1. Read the failing output in full.
2. Fix only `lib/presentation/ui/widgets/transaction_card.dart` and `test/presentation/ui/widgets/transaction_card_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit

1. Set this block's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/transaction_card.dart test/presentation/ui/widgets/transaction_card_test.dart PLAN.md
   git commit -m "Open transaction editing by tapping the card"
   ```

### Next

Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

## BLOCK 2 — Point the edit e2e helper at the card and update the test map

**Depends on:** BLOCK 1 committed
**Touches:** `integration_test/edit_transaction_test.dart` (MODIFY), `docs/test-map.md` (MODIFY)

### Goal

The e2e helper opens the edit dialog by tapping the card instead of the removed pencil icon, and `docs/test-map.md` no longer describes a pencil button.

### Context to read first

1. `integration_test/edit_transaction_test.dart` — lines 1–82: the doc comment (lines 9–13), the imports (lines 1–7), and the helper `openEditDialog` (lines 59–62) that this block rewrites. The four tests below line 83 are untouched.
2. `docs/test-map.md` — line 20 only: the `Edit UI` row whose Coverage cell starts with `The pencil button`.

Read exactly these. Do not open other files unless a step below names one.

### Steps

1. In `integration_test/edit_transaction_test.dart`, insert this import immediately after the line `import 'package:rich_ludo/main.dart' as app;` (line 7):
   ```dart
   import 'package:rich_ludo/presentation/ui/widgets/transaction_card.dart';
   ```
2. In the same file, replace the body of `openEditDialog` (lines 59–62) so the helper reads:
   ```dart
   Future<void> openEditDialog(WidgetTester tester) async {
     await tester.tap(find.byType(TransactionCard));
     await tester.pumpAndSettle();
   }
   ```
3. In the same file, in the doc comment (lines 9–13), replace the words `the pencil button opens` with `tapping the transaction card opens`. The rest of the comment stays.
4. In `docs/test-map.md` line 20, replace `The pencil button, the disabled scope option` with `The tappable card, the disabled scope option`.
5. Run the §5 write-only formatter on the Touches paths only:
   ```
   dart format integration_test/edit_transaction_test.dart
   ```

### Do not

- Do not run the integration test on any device: §6 records it as NOT RUN and it calls `deleteAll()` on the target device's database; this block verifies by `flutter analyze` only (§10).
- Do not modify the four `testWidgets` bodies (lines 83–173), the seed helpers, or `docs/test-map.md` beyond line 20.

### Verify

Run from the repository root, in this order:
```
flutter analyze
```
Expected: exits 0 and prints `No issues found!` — this proves the new import resolves and the file compiles after the `Icons.edit` reference was removed in BLOCK 1.

### If verification fails

1. Read the failing output in full.
2. Fix only `integration_test/edit_transaction_test.dart` and `docs/test-map.md`.
3. Re-run the command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit

1. Set this block's row in §12 Status to `DONE`.
2. Run:
   ```
   git add integration_test/edit_transaction_test.dart docs/test-map.md PLAN.md
   git commit -m "Tap the card in the edit e2e helper and update the test map"
   ```

### Next

Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

## BLOCK 3 — Verify the whole task and remove the plan

**Depends on:** BLOCK 2 committed
**Touches:** `PLAN.md` (deleted)

### Goal

Prove the task is complete against §2, then remove the plan from the repository.

### Context to read first

1. §2 Definition of done — the list you are about to check.
2. §6 Baseline — the numbers you compare against.

### Steps

1. Run every gate in §5 that CI runs, in CI's order (the debug build stands in for the keystore-gated release build):
   ```
   flutter analyze
   flutter test
   flutter build apk --debug
   ```
   The project has no headless run-the-app command (§5: NONE FOUND); the debug APK build is the runtime gate.
2. Check each `- [ ]` item in §2 by running the command or reading the file named in it. Every item must pass. Two of them, verbatim:
   ```
   grep -rn "Icons.edit" lib/
   flutter test test/presentation/ui/widgets/transaction_card_test.dart
   ```
   The `grep` must print nothing; the `flutter test` must report `4 passed`.
3. Only if steps 1–2 all passed:
   ```
   git rm -q PLAN.md
   ```

### Do not

- Do not delete the plan if any check failed — that is a stop condition (§11 R12).
- Do not fix a failure that §6 Baseline already recorded (the 5 unformatted files).
- Do not run `dart format` on the whole repository, and do not push, tag, or open a pull request.

### Verify

```
git status --porcelain
ls PLAN.md 2>&1
```
Expected: `git status --porcelain` lists a staged deletion (a line starting with `D `) for
`PLAN.md` and nothing else; `ls` reports "No such file or directory".

A modified file that is neither of those means a gate rewrote it (§5 `write-only`) or a block
left work behind: that is a stop condition.

### If verification fails

Follow §11 R12. Restore the plan with `git checkout -- PLAN.md` if it was already removed.

### Commit

`git rm` already staged the deletion, so nothing needs adding:
```
git commit -m "Complete tap-to-edit and remove PLAN.md"
```
Do not run `git add -A` or `git commit -a` here: they would sweep in the paths §6 recorded.

### Next

Nothing. The plan is finished. Report to the human: branch name, the list of commits
(`git log --oneline de24ea85b45ebf44a273ae15c8fb435bd702d6c5..HEAD`), and every gate result from step 1.

## Blocked

Empty while things go well. The executor appends failures here per §11 R12.
