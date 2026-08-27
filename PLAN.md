# PLAN — User-created transaction categories

Machine-readable execution plan. Audience: the LLM executing it. Follow it literally.
Progress lives in §12 Status. Start with §11.

## 1. Task

Let the user create their own transaction categories, in addition to the 9 `ExpenseCategory`
and 4 `IncomeCategory` enum values that are hard-coded today, without altering a single row a
user already stored. The 13 enum values stay exactly as they are and keep being written to
`transactions.category` as their `.name`; a new SQLite table `categories` (database version 3)
stores only the categories the user creates. The v2→v3 migration creates that one table and
never reads or writes `transactions` or `recurring_exclusions`. Each user-created category has
a name typed by the user, an icon picked from a fixed grid, and a color picked from a fixed
palette; it is written to `transactions.category` as a slug prefixed with `custom_`, which can
never collide with any of the 13 built-in `.name` values. The user creates and deletes
categories in one `CategoryManagerDialog`, reached from a `+ Nova categoria` entry at the
bottom of the category dropdown of the transaction dialog; deleting is refused while any
transaction still carries the category, and the dialog then states how many transactions use
it.

## 2. Definition of done

Every item is checkable by running a named command or reading a named file.

- [ ] `DatabaseConfig.databaseVersion` is `3` and `DatabaseConfig.categoriesTableName` is `'categories'` (read `lib/config/database_config.dart`).
- [ ] A version 1 database and a version 2 database both reach version 3 with every `transactions` and `recurring_exclusions` row unchanged (covered by `test/data/database/database_migration_test.dart`).
- [ ] `CustomCategory.slugFor('Mercado')` returns `'custom_mercado'` and no return value of `slugFor` can equal any `ExpenseCategory` or `IncomeCategory` `.name` (covered by `test/domain/model/custom_category_test.dart`).
- [ ] `CategoryLocalService` inserts, lists and deletes rows of the `categories` table against a real FFI SQLite database (covered by `test/data/services/category_local_service_test.dart`).
- [ ] `CreateCustomCategoryUseCase` refuses an empty name, a name longer than 30 characters, and a name that duplicates an existing category of the same type (covered by `test/domain/usecase/create_custom_category_usecase_test.dart`).
- [ ] `DeleteCustomCategoryUseCase` returns `CategoryInUseException` carrying the exact number of transactions that use the category, and deletes only when that number is 0 (covered by `test/domain/usecase/delete_custom_category_usecase_test.dart`).
- [ ] `CategoryViewModel` reloads its list after a successful create and after a successful delete (covered by `test/presentation/viewmodel/category_viewmodel_test.dart`).
- [ ] `CategoryManagerDialog` shows the duplicate-name message, shows the in-use message with the transaction count, and returns the new slug when creating succeeds (covered by `test/presentation/ui/widgets/category_manager_dialog_test.dart`).
- [ ] `getCategoryIcon`, `getExpenseCategoryColor` and `getExpenseCategoryLabel` resolve a user-created slug to its stored icon, color and name (covered by `test/presentation/ui/utils/category_icon_test.dart`, `test/presentation/ui/utils/category_color_test.dart`, `test/presentation/ui/utils/category_mapper_test.dart`).
- [ ] `grep -c 'customCategories:' lib/presentation/ui/screens/main_screen.dart` prints `4`, proving `MainScreen` passes the real list into both `_TransactionContent` and `_ChartContent` and on to `TransactionList` and `ChartScreen`.
- [ ] `flutter build apk --release` exits 0, proving the icon font tree-shaking still works with the picker grid.
- [ ] All gates in §5 pass at least as well as §6 Baseline.
- [ ] `PLAN.md` no longer exists, and neither does `PLAN/`.

## 3. Out of scope

- Renaming or editing an existing user-created category. Only create and delete are built.
- Turning any of the 13 built-in enum values into a database row, deleting a built-in category, or changing its icon or color.
- Migrating, rewriting or deleting any existing row of `transactions` or `recurring_exclusions`.
- Letting the user pick an arbitrary color or an arbitrary icon outside the two fixed lists this plan defines.
- Exporting or importing user-created categories separately: the backup already copies the whole `.db` file, so the `categories` table travels with it.
- Fixing any entry of `docs/known-issues.md`, including the zero-value amount, the Spanish locale that `RichLudoApp` never selects, and the unused `TransactionDao`.
- Bumping `version:` in `pubspec.yaml`, writing a release section in `CHANGELOG.md`, or creating a git tag. That is the `generate-version` skill's job.

## 4. Branch

Branch: `feat/custom-categories`
Base: `main` at `588d5f4`
Created for this task.

All work happens on this branch. See §11 R4.

## 5. Project facts

Every command below was read from the file cited. A row marked `NONE FOUND` must never be run.
A row marked `write-only` rewrites files: it belongs in a block's Steps, never in a **Verify**
list and never in the final block's gate list.

| Fact | Value | Source |
|---|---|---|
| Package manager | pub, via the Flutter SDK | `pubspec.lock` |
| Flutter version | 3.44.8, Dart 3.12.2 | `flutter --version` |
| Install | `flutter pub get` | `.github/workflows/build-release.yml:37` |
| Unit tests (all) | `flutter test` | `.github/workflows/build-release.yml:40` |
| Unit tests (one file) | `flutter test <path>` | `AGENTS.md:93` |
| Lint | `flutter analyze` | `AGENTS.md:95` |
| Type check | same command as Lint: `flutter analyze` | `AGENTS.md:95` |
| Format check | NONE FOUND | `docs/test-map.md:38` records only the rewriting form |
| Format write (`write-only`) | `dart format <paths>` | `docs/test-map.md:38` |
| Localization codegen (`write-only`) | `flutter gen-l10n` | `l10n.yaml`, `pubspec.yaml:88` (`generate: true`) |
| Build | `flutter build apk --release` | `.github/workflows/build-release.yml:54` |
| E2E | `flutter test integration_test/chart_orientation_test.dart -d <device>` | `integration_test/chart_orientation_test.dart:16` |
| Run the app | `flutter run` — needs an Android or iOS device; `flutter devices` lists only Linux desktop and Chrome here, and the project targets Android and iOS only | `README.md:153`, `README.md:141` |
| CI gates, in order | `flutter pub get`, `flutter test`, `flutter build apk --release` | `.github/workflows/build-release.yml:37,40,54` |
| Commit style | one line, sentence case, imperative, no trailing period, no scope prefix | `git log` |
| Commit examples | `Add LICENSE AND CHANGELOG` / `Fix Color and Add Horizontal Gesture` | `git log` |

`flutter analyze` is not a CI job but `AGENTS.md:95` names it as the project's lint command and
§6 records it clean, so every block runs it.

`dart format` and `flutter gen-l10n` rewrite files. Run each only on the paths a block lists in
**Touches**, as the block's steps instruct, and never as a **Verify** command.

## 6. Baseline — recorded 2026-08-26

| Gate | Command | Result |
|---|---|---|
| Install | `flutter pub get` | clean; prints `35 packages have newer versions incompatible with dependency constraints` |
| Lint | `flutter analyze` | clean — `No issues found!` |
| Unit | `flutter test` | `All tests passed!`, 218 tests |
| Build | `flutter build apk --release` | exit 0 in 60s, `Built build/app/outputs/flutter-apk/app-release.apk`; prints `Font asset "MaterialIcons-Regular.otf" was tree-shaken, reducing it from 1645184 to 4000 bytes`; `android/key.properties` is absent, so `android/app/build.gradle.kts:51` falls back to the debug signing config |
| Localization codegen | `flutter gen-l10n` | rewrites `lib/l10n/app_localizations*.dart` in place and leaves `git status` clean |
| E2E | `flutter test integration_test/chart_orientation_test.dart -d <device>` | NOT RUN — no Android or iOS device or emulator is attached; `flutter devices` lists only Linux desktop and Chrome |

Known pre-existing failures: `dart format --output=none --set-exit-if-changed lib test integration_test`
exits 1 and names 7 already-unformatted files: `lib/data/services/transaction_local_service.dart`,
`lib/domain/usecase/get_non_recurring_balance_usecase.dart`, `lib/main.dart`,
`test/data/repository/transaction_repository_impl_test.dart`, `test/fakes/fake_transaction_repository.dart`,
`test/fakes/fake_transaction_service.dart`, `test/presentation/ui/utils/category_icon_test.dart`.
That is why §5 records no format-check gate. Blocks run `dart format` only on their own
**Touches** paths, which reformats a file listed here when the block already edits it — that is
expected and belongs in that block's commit.

A failure listed here is not caused by this plan: do not fix it, do not let it block a block (§11 R12).

Pre-existing uncommitted paths: None.
These paths are not yours: never stage them, never revert them. The final block expects to see
them in `git status`.

## 7. Architecture and style rules that bind this task

1. Layers run Service → Repository → UseCase → ViewModel → View, wired with `Provider` in `lib/main.dart`; a widget never touches a service or a repository — `AGENTS.md:5-20`.
2. Every async operation returns `Result<T>` (`Ok<T>` | `Error<T>`) and every service method wraps its body in `try` / `on Exception catch (e) { return Result.error(e); }` — `AGENTS.md:22`, `lib/data/services/transaction_local_service.dart:22-32`.
3. Every ViewModel is a `ChangeNotifier` and wraps async work in `Command0` / `Command1` / `Command2` from `lib/utils/command.dart` — `AGENTS.md:23`.
4. Domain models are immutable and implement `copyWith()`, `operator ==` and `hashCode`; a nullable field that must be clearable takes a `T? Function()?` parameter in `copyWith` — `AGENTS.md:27`, `lib/domain/model/transaction.dart:47-48`.
5. Code, comments, test names and identifiers are English; every user-facing string comes from `AppLocalizations` and is declared in `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb` — `AGENTS.md:32`.
6. Never duplicate code, and never declare the same string or constant twice — `AGENTS.md:34-35`.
7. Money is `int amountCents`; a date is `targetMonth` (1-12), `targetYear` and `createdAt` in epoch milliseconds — `AGENTS.md:29-30`.
8. Tests mirror `lib/` under `test/`: use-case tests use a fake from `test/fakes/`, repository tests use a mocktail `Mock` of the service, ViewModel tests use mocktail `Mock`s of the use cases and always call `dispose()` — `AGENTS.md:40-63`, `test/domain/usecase/make_transaction_usecase_test.dart:7-15`, `test/presentation/viewmodel/main_screen_viewmodel_test.dart:20-36`.

NOTE: `docs/project-map.md:12` shows only `TransactionLocalService` in the dependency graph and
`docs/database.md:5` says the current database version is 2. Both become stale the moment BLOCK 1
lands; BLOCK 13 updates them. Until then the code wins.

## 8. Security invariants

No security documentation found in this repository. Baseline invariants apply: never log or
commit secrets; never interpolate untrusted input into SQL, HTML, shell, or file paths;
never remove or bypass an existing authentication or authorization check; never widen a CORS,
cookie, or permission setting.

One concrete consequence for this task: the category name is typed by the user and is the only
untrusted input it introduces. Every statement that stores or matches it goes through
`sqflite`'s placeholder arguments (`whereArgs`, or the map passed to `db.insert`), exactly as
`lib/data/services/transaction_local_service.dart:143-151` does. Never build a SQL string by
interpolating a name, a slug, or an id.

## 9. Quality bars

Violating any of these is a defect even when the tests pass.

- Never build `IconData` from a stored integer at runtime (`IconData(codePoint)`); always look the code point up in the `const` list `customCategoryIcons` and return the `const` entry. A runtime-built `IconData` breaks the icon-font tree-shaking that `flutter build apk --release` performs, which is a §5 gate.
- Never write `Color.value`: it is deprecated in Flutter 3.44 and `flutter analyze` fails on the resulting hint. Use `Color.toARGB32()` to store and `Color(storedValue)` to read back.
- The `custom_` prefix, the slug builder, the icon list and the color palette each exist in exactly one place. Do not re-derive a slug anywhere except `CustomCategory.slugFor`, and do not write the literal `'custom_'` anywhere except `CustomCategory.slugPrefix`.
- Do not add a `CategoryDao`, a `CategoryCache`, a category registry, or a base class shared by built-in and user-created categories. Built-in categories stay enums; user-created categories stay rows.
- Do not add a `CustomCategoryLabelFormatter`, `IconPickerController`, or any other new class for a single caller. `CategoryManagerDialog` owns its own picker state in its `State`.
- Do not give `CategoryLocalService` a method that reads the `transactions` table. Counting the transactions that use a category is `DeleteCustomCategoryUseCase`'s job, through `TransactionRepository.getTransactions()`, mirroring `lib/domain/usecase/make_transaction_usecase.dart:21`.
- Do not add a method to `TransactionService`, `TransactionRepository`, `test/fakes/fake_transaction_service.dart` or `test/fakes/fake_transaction_repository.dart`. Nothing in this plan needs one.
- Do not add a configuration option, an environment variable, or a feature flag for the category limit, the palette size, or the icon grid size.
- Do not write a test whose only assertion is that a widget builds. Every new test asserts a value the block's own change produces.
- When "avoid duplication" and "avoid over-engineering" conflict, choose the smaller diff: duplicate once, extract on the third occurrence.

## 10. Test obligations

| Kind | Required | Why | Location | Command |
|---|---|---|---|---|
| Model | yes | `CustomCategory` is a new immutable model with a slug builder | `test/domain/model/custom_category_test.dart` | `flutter test test/domain/model/custom_category_test.dart` |
| Migration (FFI SQLite) | yes | database version 3 must not lose a single existing row | `test/data/database/database_migration_test.dart` | `flutter test test/data/database/database_migration_test.dart` |
| Service (FFI SQLite) | yes | `CategoryLocalService` owns new SQL, including the `UNIQUE (slug, type)` constraint | `test/data/services/category_local_service_test.dart` | `flutter test test/data/services/category_local_service_test.dart` |
| Repository | yes | `CategoryRepositoryImpl` delegates and must propagate `Result` | `test/data/repository/category_repository_impl_test.dart` | `flutter test test/data/repository/category_repository_impl_test.dart` |
| Use case | yes | validation and the in-use rule are the business logic of this task | `test/domain/usecase/create_custom_category_usecase_test.dart`, `test/domain/usecase/delete_custom_category_usecase_test.dart` | `flutter test test/domain/usecase/` |
| ViewModel | yes | `CategoryViewModel` and the changed `TransactionFormViewModel` hold new state | `test/presentation/viewmodel/category_viewmodel_test.dart`, `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` | `flutter test test/presentation/viewmodel/` |
| Widget | yes | `CategoryManagerDialog` is the only place create and delete errors reach the user | `test/presentation/ui/widgets/category_manager_dialog_test.dart` | `flutter test test/presentation/ui/widgets/category_manager_dialog_test.dart` |
| UI utility | yes | the three resolution helpers gain a new branch each | `test/presentation/ui/utils/` | `flutter test test/presentation/ui/utils/` |
| Release build smoke | yes | the icon picker is the only thing in this task that static checks cannot catch | — | `flutter build apk --release` |
| E2E | no | `integration_test/chart_orientation_test.dart` needs an Android or iOS device and §6 records none attached; BLOCK 14 reports the exact command for the human to run | `integration_test/` | `flutter test integration_test/chart_orientation_test.dart -d <device>` |

`GetCustomCategoriesUseCase` gets no file of its own: it is a one-line delegation and every
branch of it is exercised through `test/presentation/viewmodel/category_viewmodel_test.dart`,
matching `lib/domain/usecase/get_non_recurring_balance_usecase.dart`, which also has no test file.

Follow the existing test style at `test/domain/usecase/make_transaction_usecase_test.dart` for
use cases, `test/data/services/transaction_local_service_test.dart` for FFI SQLite,
`test/presentation/viewmodel/main_screen_viewmodel_test.dart` for ViewModels, and
`test/presentation/ui/screens/chart_screen_test.dart` for widgets.

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
is not `feat/custom-categories`, stop (R12). Never leave, hide or rewrite the branch's work: no
`git checkout feat/custom-categories`, `git switch`, `git merge`, `git rebase`, `git reset`, `git stash`,
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
| 1 | Add the `categories` table and the v3 migration | `PLAN/01-schema-v3.md` | DONE |
| 2 | Add the `CustomCategory` model and its mapper | `PLAN/02-model.md` | DONE |
| 3 | Add `CategoryService` and `CategoryLocalService` | `PLAN/03-service.md` | DONE |
| 4 | Add `CategoryRepository` and `CategoryRepositoryImpl` | `PLAN/04-repository.md` | DONE |
| 5 | Add the three category use cases | `PLAN/05-usecases.md` | DONE |
| 6 | Add `CategoryViewModel` and wire it in `main.dart` | `PLAN/06-viewmodel-di.md` | TODO |
| 7 | Add the category localization keys | `PLAN/07-l10n.md` | TODO |
| 8 | Resolve icon, color and label for user-created slugs | `PLAN/08-resolution.md` | TODO |
| 9 | Replace the two form category fields with one slug | `PLAN/09-form-slug.md` | TODO |
| 10 | Add `CategoryManagerDialog` | `PLAN/10-manager-dialog.md` | TODO |
| 11 | Offer user-created categories in the transaction dropdown | `PLAN/11-dropdown-wiring.md` | TODO |
| 12 | Pass the user-created categories to the list and the chart | `PLAN/12-widget-threading.md` | TODO |
| 13 | Update the documentation and the changelog | `PLAN/13-docs.md` | TODO |
| 14 | Verify everything and remove the plan | `PLAN/14-cleanup.md` | TODO |

Statuses: `TODO` → `DONE`, or `BLOCKED` (see §11 R12).

## 13. Blocks

- `PLAN/01-schema-v3.md`
- `PLAN/02-model.md`
- `PLAN/03-service.md`
- `PLAN/04-repository.md`
- `PLAN/05-usecases.md`
- `PLAN/06-viewmodel-di.md`
- `PLAN/07-l10n.md`
- `PLAN/08-resolution.md`
- `PLAN/09-form-slug.md`
- `PLAN/10-manager-dialog.md`
- `PLAN/11-dropdown-wiring.md`
- `PLAN/12-widget-threading.md`
- `PLAN/13-docs.md`
- `PLAN/14-cleanup.md`

## Blocked
