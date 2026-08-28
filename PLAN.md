# PLAN — Edit an existing transaction

Machine-readable execution plan. Audience: the LLM executing it. Follow it literally.
Progress lives in §12 Status. Start with §11.

## 1. Task

Add editing of an existing transaction to RichLudo. Every card in the transaction list gains a
pencil `IconButton` beside its delete button; tapping it opens the existing `TransactionDialog`
pre-filled with that transaction, where the user can change the type, the category, the amount,
the notes and the `Repete` switch. Saving a one-off transaction writes the row through a new
`UpdateTransactionUseCase`. Saving a transaction that is already recurring first asks for a
scope through the same four-option dialog the delete flow uses — `Apenas este mês`,
`Este mês e anteriores`, `Este mês e futuros`, `Todos os meses` — and a new
`UpdateRecurringTransactionUseCase` applies it. When the user turns the `Repete` switch off on a
transaction that is already recurring, the scope dialog renders `Este mês e anteriores` disabled
and non-tappable, because a one-off row cannot cover past months. The delete flow's enum and
dialog are renamed to the neutral `RecurringScope` and `RecurringScopeDialog` so both flows share
one implementation, and the month arithmetic both use cases need moves into a new `MonthYear`
domain model. The plan ends by adding a `## Reuse` section to `AGENTS.md`, and by cutting release
`v3.0.0` through the steps in `.claude/skills/generate-version/SKILL.md`.

Decided semantics for a transaction that is already recurring, where `original` is the stored row,
`edited` carries the new values, and `(month, year)` is the month shown on screen:

| Scope | Effect |
|---|---|
| `allMonths` | Update the stored row in place with the edited values. When `edited.isRecurring` is false, delete that transaction's exclusions first. |
| `thisMonth` | Add an exclusion for `(month, year)`, then insert a new one-off row carrying the edited values at `targetMonth: month, targetYear: year`. The stored rule is otherwise untouched. |
| `thisAndPreviousMonths` | Move the stored row's start to the month after `(month, year)`, then insert a new recurring row carrying the edited values from the original start through `(month, year)`. Reachable only while `edited.isRecurring` is true. |
| `thisAndFutureMonths` | End the stored row at the month before `(month, year)`, then insert a new row carrying the edited values starting at `(month, year)`: recurring and inheriting the original end when `edited.isRecurring` is true, one-off when it is false. |

Each of the three splitting scopes collapses to the `allMonths` effect when the edited range already
covers the whole rule, mirroring `DeleteRecurringTransactionUseCase`.

Fields never changed by an edit: `id`, `createdAt`, `humanDate`. `targetMonth` and `targetYear`
change only on the stored row of a splitting scope, and on an inserted copy as the table above states.

## 2. Definition of done

Every item is checkable by running a named command or reading a named file.

- [ ] `flutter test test/domain/model/month_year_test.dart` exits 0.
- [ ] `grep -rn "RecurringDeleteMode\|RecurringDeleteDialog" lib test integration_test` prints nothing.
- [ ] `grep -l "recurringEditTitle" lib/l10n/app_pt.arb lib/l10n/app_en.arb lib/l10n/app_es.arb` prints all three paths.
- [ ] `flutter test test/domain/usecase/update_transaction_usecase_test.dart test/domain/usecase/update_recurring_transaction_usecase_test.dart` exits 0.
- [ ] `grep -n "startEditing\|isEditing\|buildEditedTransaction" lib/presentation/viewmodel/transaction_form_viewmodel.dart` prints at least one line per name.
- [ ] `grep -n "Icons.edit" lib/presentation/ui/widgets/transaction_card.dart` prints one line.
- [ ] `grep -n "updateItem\|updateRecurringItem" lib/presentation/viewmodel/main_screen_viewmodel.dart` prints both names.
- [ ] `flutter test integration_test/edit_transaction_test.dart -d emulator-5554` exits 0 and reports 4 passing tests.
- [ ] `grep -n "^## Reuse" AGENTS.md` prints one line.
- [ ] `grep -n "^version: 3.0.0+13" pubspec.yaml` prints one line, `grep -n "^## \[3.0.0\]" CHANGELOG.md` prints one line, `grep -n "version-3.0.0-green" README.md` prints one line, and `git tag --list v3.0.0` prints `v3.0.0`.
- [ ] All gates in §5 pass at least as well as §6 Baseline.
- [ ] `PLAN.md` no longer exists, and neither does `PLAN/`.

## 3. Out of scope

- Moving an exclusion from a split rule onto the copy that replaces it. `DeleteRecurringTransactionUseCase` already leaves exclusions attached to the original id when it moves a rule's start or end, and this task keeps that behaviour.
- Replacing the month arithmetic inside `lib/presentation/viewmodel/main_screen_viewmodel.dart` (`_isOnOrBefore`, `_recurringContributionToSavings`, `goToPreviousMonth`, `goToNextMonth`) with `MonthYear`.
- Editing `humanDate` or `createdAt`, and adding a date field to `TransactionDialog`.
- Editing a transaction from the landscape chart. The chart draws no cards.
- Wiring `lib/data/local/dao/transaction_dao.dart` into any path.
- Adding an FFI SQLite test for `TransactionLocalService.updateTransaction`. That method already exists at `lib/data/services/transaction_local_service.dart:167` and this task changes no SQL.
- Pushing the branch or the tag, opening a pull request, and running `flutter build apk --release`.

## 4. Branch

Branch: `feat/edit-transactions`
Base: `main` at `a69f001`
Created for this task.

All work happens on this branch. See §11 R4.

## 5. Project facts

Every command below was read from the file cited. A row marked `NONE FOUND` must never be run.
A row marked `write-only` rewrites files: it belongs in a block's Steps, never in a **Verify**
list and never in the final block's gate list.

| Fact | Value | Source |
|---|---|---|
| Package manager | pub, through the Flutter SDK | `pubspec.lock` |
| Install | `flutter pub get` | `.github/workflows/build-release.yml:37` |
| Unit tests (all) | `flutter test` | `AGENTS.md:93` |
| Unit tests (one file) | `flutter test <path>` | `AGENTS.md:93` |
| Lint and type check | `flutter analyze` | `AGENTS.md:95` |
| Format check | NONE FOUND | `.github/workflows/build-release.yml` declares no format step |
| Format write (`write-only`) | `dart format <paths>` | `docs/test-map.md:42` |
| Localization codegen (`write-only`) | `flutter gen-l10n` | `l10n.yaml:1-3` |
| Build | `flutter build apk --debug` | `docs/project-map.md:50` |
| E2E | `flutter test integration_test/<file> -d emulator-5554` | `integration_test/custom_categories_test.dart:15` |
| Run the app | `flutter run -d emulator-5554` | `README.md:154` |
| CI gates, in order | `flutter pub get`, `flutter test`, `flutter build apk --release` | `.github/workflows/build-release.yml:36-54` |
| Release procedure | steps 3 to 7 of the project skill | `.claude/skills/generate-version/SKILL.md:14-22` |
| Commit style | one line, sentence case, imperative, no prefix; release commits use `chore: release vX.Y.Z` | `git log` |
| Commit examples | `Add the categories table in database version 3` / `Render user-created categories in the transaction list and the chart` | `git log` |

The single connected Android device is `emulator-5554`, reported by `flutter devices`. Every e2e
command in this plan targets it by that exact id.

**One deliberate exception to §11 R4.** R4 forbids `git tag` because tagging is one of the ways a
branch's work gets hidden or rewritten. BLOCK 14 is the single place in this plan allowed to run it:
the project's release procedure ends with an annotated tag
(`.claude/skills/generate-version/SKILL.md:22`), that tag is created only after every gate in BLOCK
14 has passed, and it is never pushed. This is not a contradiction to stop on (§11 R12) — it is a
named, scoped permission. No other block may run `git tag`, and every other prohibition in R4 stands
for BLOCK 14 too, `git push` included.

## 6. Baseline — recorded 2026-08-27

| Gate | Command | Result |
|---|---|---|
| Unit | `flutter test` | 290 passed, 0 failed |
| Lint and type check | `flutter analyze` | clean — `No issues found!` |
| Localization codegen | `flutter gen-l10n` | clean — leaves `git status --porcelain` empty |
| E2E categories | `flutter test integration_test/custom_categories_test.dart -d emulator-5554` | 4 passed |
| E2E chart | `flutter test integration_test/chart_orientation_test.dart -d emulator-5554` | 3 passed |
| Build | `flutter build apk --debug` | succeeds — the e2e runs above print `Built build/app/outputs/flutter-apk/app-debug.apk` |
| Build release APK | `flutter build apk --release` | NOT RUN — it needs the signing keystore described in `README.md:119-137`, which is not in this working tree. CI runs it. |

Known pre-existing failures: None.

Five files are already not `dart format` clean: `lib/data/services/transaction_local_service.dart`,
`lib/domain/usecase/get_non_recurring_balance_usecase.dart`,
`test/data/repository/transaction_repository_impl_test.dart`,
`test/fakes/fake_transaction_repository.dart`, `test/fakes/fake_transaction_service.dart`.
No block runs the formatter on a path outside its own **Touches** list, so those five files stay
as they are unless a block already edits them.

Pre-existing uncommitted paths: None.
These paths are not yours: never stage them, never revert them. The final block expects to see
them in `git status`.

## 7. Architecture and style rules that bind this task

Only rules this task can actually violate. Each cites where it comes from.

1. Keep the layers: a use case depends on the abstract `TransactionRepository` and on nothing from `lib/presentation/` or `lib/data/`; a ViewModel depends on use cases; a widget depends on ViewModels — `AGENTS.md:5-23`.
2. Cross-layer results are `Result<T>` (`Ok<T>` or `Error<T>`); never throw across a layer boundary — `AGENTS.md:22`.
3. Domain models are immutable and expose `copyWith()`, `==` and `hashCode` — `AGENTS.md:26`.
4. Money stays `int amountCents` and is rendered through `formatMoney()` in `lib/presentation/ui/utils/money_formatter.dart` — `AGENTS.md:30`.
5. No duplicated code and no string built in two places; every user-facing string is one key present in all three of `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb` — `AGENTS.md:33-36`.
6. Code, comments and test names are written in English; user-facing text reaches the screen only through `AppLocalizations` — `AGENTS.md:33`.
7. A widget used in one file only is private and named `_NameWidget` — `AGENTS.md:28`.
8. A ViewModel test calls `dispose()` at its end, and `setUpAll()` registers every `registerFallbackValue` the file needs — `AGENTS.md:52-53`.

NOTE: `docs/project-map.md:41` says `lib/data/local/dao/transaction_dao.dart` is not part of the
active path. `grep -rn "TransactionDao" lib/` confirms it: nothing imports it. The code wins and
the doc agrees; do not wire it into this task.

## 8. Security invariants

No security documentation found in this repository. Baseline invariants apply: never log or
commit secrets; never interpolate untrusted input into SQL, HTML, shell, or file paths;
never remove or bypass an existing authentication or authorization check; never widen a CORS,
cookie, or permission setting.

## 9. Quality bars

Violating any of these is a defect even when the tests pass.

- Do not copy the month arithmetic out of `DeleteRecurringTransactionUseCase`: BLOCK 1 puts it in `MonthYear` and BLOCK 3 deletes the private copies. The new use case uses `MonthYear`.
- Do not declare a second scope enum or a second scope dialog. After BLOCK 2, `RecurringScope` and `RecurringScopeDialog` are the only ones, and both flows pass through them.
- Do not add a `Command3` class. `MainScreenViewModel.updateRecurringItem` awaits the use case directly and switches on its `Result`, exactly as `deleteRecurringItem` does today.
- Do not add a color constant for the pencil icon. It uses `Theme.of(context).colorScheme.onSurfaceVariant`, which the theme already defines.
- Do not write a user-facing literal in Dart. Each new string is one key added to all three `lib/l10n/app_*.arb` files and read through `AppLocalizations`.
- Do not add a `TransactionEditViewModel` or an `EditFormUiState`. The edit state lives in the existing `TransactionFormViewModel` and `FormUiState`.
- Do not make `Transaction` mutable to apply an edit. Build a new instance with `copyWith`.
- Do not run the formatter over `lib` or `test` as a whole in any block. Pass it only the paths in that block's **Touches** list.
- Do not move an exclusion onto a copy created by a splitting scope; §3 puts that out of scope.
- When "avoid duplication" and "avoid over-engineering" conflict, choose the smaller diff: duplicate once, extract on the third occurrence.

## 10. Test obligations

| Kind | Required | Why | Location | Command |
|---|---|---|---|---|
| Unit | yes | one new domain model, two new use cases, one changed use case, two changed ViewModels | `test/domain/model/`, `test/domain/usecase/`, `test/presentation/viewmodel/` | `flutter test <path>` |
| Widget | yes | a new dialog parameter, a pre-filled form, a new button on the card | `test/presentation/ui/widgets/` | `flutter test <path>` |
| Integration (FFI SQLite) | no | this task writes no SQL; `TransactionLocalService.updateTransaction` already exists at `lib/data/services/transaction_local_service.dart:167` and is unchanged | — | — |
| E2E | yes | a new user-visible flow, requested to follow the existing mold | `integration_test/edit_transaction_test.dart` | `flutter test integration_test/edit_transaction_test.dart -d emulator-5554` |
| Smoke (run the app) | yes | the card row gains a second button; a `RenderFlex` overflow is invisible to `flutter analyze` | — | the e2e command above, which builds and installs the debug APK |

Follow the existing test style at `test/domain/usecase/delete_recurring_transaction_usecase_test.dart`
for use cases, `test/presentation/ui/widgets/transaction_dialog_test.dart` for widgets, and
`integration_test/custom_categories_test.dart` for e2e.

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
is not `feat/edit-transactions`, stop (R12). Never leave, hide or rewrite the branch's work: no
`git checkout feat/edit-transactions`, `git switch`, `git merge`, `git rebase`, `git reset`, `git stash`,
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
| 1 | Add the MonthYear domain model | `PLAN/01-month-year.md` | TODO |
| 2 | Rename the recurring delete mode and dialog to a neutral scope | `PLAN/02-recurring-scope-rename.md` | TODO |
| 3 | Move the delete use case onto MonthYear | `PLAN/03-delete-usecase-month-year.md` | TODO |
| 4 | Add the edit localization keys | `PLAN/04-l10n-edit-keys.md` | TODO |
| 5 | Let the scope dialog disable one option | `PLAN/05-scope-dialog-disabled.md` | TODO |
| 6 | Add UpdateTransactionUseCase | `PLAN/06-update-transaction-usecase.md` | TODO |
| 7 | Add UpdateRecurringTransactionUseCase | `PLAN/07-update-recurring-usecase.md` | TODO |
| 8 | Give the form ViewModel an edit mode | `PLAN/08-form-viewmodel-edit.md` | TODO |
| 9 | Pre-fill the transaction dialog and route its edit submit | `PLAN/09-dialog-prefill.md` | TODO |
| 10 | Add the update commands to the main ViewModel and provide the use cases | `PLAN/10-main-viewmodel-update.md` | TODO |
| 11 | Add the pencil button and wire the edit flow into the main screen | `PLAN/11-card-edit-wiring.md` | TODO |
| 12 | Add the edit e2e test | `PLAN/12-e2e-edit.md` | TODO |
| 13 | Document the feature and tighten the reuse rule | `PLAN/13-docs.md` | TODO |
| 14 | Verify everything, release v3.0.0 and remove the plan | `PLAN/14-release.md` | TODO |

Statuses: `TODO` → `DONE`, or `BLOCKED` (see §11 R12).

## 13. Blocks

Each block lives in its own file. Open only the one §12 points at.

- `PLAN/01-month-year.md`
- `PLAN/02-recurring-scope-rename.md`
- `PLAN/03-delete-usecase-month-year.md`
- `PLAN/04-l10n-edit-keys.md`
- `PLAN/05-scope-dialog-disabled.md`
- `PLAN/06-update-transaction-usecase.md`
- `PLAN/07-update-recurring-usecase.md`
- `PLAN/08-form-viewmodel-edit.md`
- `PLAN/09-dialog-prefill.md`
- `PLAN/10-main-viewmodel-update.md`
- `PLAN/11-card-edit-wiring.md`
- `PLAN/12-e2e-edit.md`
- `PLAN/13-docs.md`
- `PLAN/14-release.md`

## Blocked

