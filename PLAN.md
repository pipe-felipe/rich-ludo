# PLAN — Landscape expenses-by-category pie chart

Machine-readable execution plan. Audience: the LLM executing it. Follow it literally.
Progress lives in §12 Status. Start with §11.

## 1. Task

Replace the WIP chart-navigation button with an orientation-driven view: while the device is in
landscape, `MainScreen` renders a pie chart of the open month's expenses grouped by category;
in portrait it renders the existing transaction list. The aggregation is computed inside
`MainScreenViewModel._filterAndComputeTotals()` from the already-filtered `_items` list and
exposed through a getter — no new UseCase, no second repository query. Category slice colors are
constants in `lib/presentation/ui/theme/app_colors.dart`, resolved by
`lib/presentation/ui/utils/category_color.dart`, which mirrors the existing
`lib/presentation/ui/utils/category_icon.dart`. `_ChartNavigatorButton` and the
`chart_screen.dart` import are removed from `main_top_bar.dart`; the rename
`_IncomeExpenseBar` → `_IncomeExpenseColorBar` stays. There is no new route and no
`Navigator.push`.

Decided during planning, both by the user: (1) new test names are written in **English**
(`test('should ...')`) to match the 172 existing tests and `docs/test-map.md:24`, and
`AGENTS.md:50` is corrected to stop contradicting the codebase; (2) the build gate is
`flutter build apk --debug`, the same command `docs/project-map.md:44` names — it was failing on
this machine before planning and a Temurin JDK 17 was installed to unblock it, see §6.

## 2. Definition of done

Every item is checkable by running a named command or reading a named file.

- [ ] `grep -c "expenseByCategory" lib/presentation/viewmodel/main_screen_viewmodel.dart` prints `4` or more, and `flutter test test/presentation/viewmodel/main_screen_viewmodel_test.dart` exits 0 printing `+33: All tests passed!`.
- [ ] `grep -rn "_ChartNavigatorButton\|chart_screen.dart" lib/presentation/ui/widgets/main_top_bar.dart` prints nothing.
- [ ] `grep -rn "Navigator.push" lib/` prints nothing.
- [ ] `grep -n "_IncomeExpenseColorBar" lib/presentation/ui/widgets/main_top_bar.dart` prints at least 2 lines.
- [ ] `grep -n "MediaQuery.orientationOf" lib/presentation/ui/screens/main_screen.dart` prints at least 1 line.
- [ ] `grep -rn "Color(0xFF" lib/presentation/ui/widgets/chart/ lib/presentation/ui/screens/chart_screen.dart` prints nothing.
- [ ] `grep -c "First\|Second\|Third\|Fourth" lib/presentation/ui/widgets/chart/pie_chart.dart` prints `0`.
- [ ] `tail -c 1 lib/presentation/ui/widgets/chart/pie_chart.dart | xxd -p` prints `0a`.
- [ ] The keys `chartTitle`, `categoryUncategorized` and `chartTotalExpense` exist in all three of `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, and `grep -c "get chartTitle" lib/l10n/app_localizations.dart` prints `1`.
- [ ] `flutter test test/presentation/ui/widgets/chart/pie_chart_test.dart test/presentation/ui/screens/chart_screen_test.dart test/domain/model/category_total_test.dart test/presentation/ui/utils/category_color_test.dart` exits 0.
- [ ] All gates in §5 pass at least as well as §6 Baseline.
- [ ] `PLAN.md` no longer exists, and neither does `PLAN/`.

## 3. Out of scope

- An income pie chart, month-over-month comparison, time series, or category filters.
- Any change to recurring visibility rules, exclusion rules, or `_computeSavingsCents()` in `lib/presentation/viewmodel/main_screen_viewmodel.dart`.
- Any change under `android/` or `ios/`: orientation is already unlocked (`android/app/src/main/AndroidManifest.xml:17` declares `orientation` in `configChanges`; `ios/Runner/Info.plist` already lists both landscape orientations).
- Changing the Gradle wrapper, the JDK setting, or anything else about the toolchain. The JDK was already fixed during planning (§6).
- Updating `docs/project-map.md`, `docs/test-map.md`, `README.md`, `CHANGELOG.md`, or `pubspec.yaml`. The only documentation edit in this plan is the one-line `AGENTS.md:50` correction in BLOCK 3.
- Adding colors for `IncomeCategory` — the chart shows expenses only.

## 4. Branch

Branch: `chart`
Base: `main` at `a5c0c91`
Reused because the session was already on a non-default branch.

All work happens on this branch. See §11 R4.

## 5. Project facts

Every command below was read from the file cited. A row marked `NONE FOUND` must never be run.
A row marked `write-only` rewrites files: it belongs in a block's Steps, never in a **Verify**
list and never in the final block's gate list.

| Fact | Value | Source |
|---|---|---|
| Package manager | Flutter / pub | `pubspec.lock`, `pubspec.yaml:1` |
| Install | `flutter pub get` | `.github/workflows/build-release.yml:98` |
| Unit tests (all) | `flutter test` | `AGENTS.md:92` |
| Unit tests (one file) | `flutter test <path>` | `AGENTS.md:92` |
| Lint / analyze | `flutter analyze` | `AGENTS.md:94` |
| Type check | same as `flutter analyze` (Dart analyzer) | `analysis_options.yaml:43` |
| Format check | NONE FOUND | — |
| Format write (`write-only`) | `dart format <paths>` | `docs/test-map.md:31` |
| Localization codegen (`write-only`) | `flutter gen-l10n` | `l10n.yaml:1-3` |
| Build | `flutter build apk --debug` | `docs/project-map.md:44` |
| E2E | NONE FOUND | — |
| Run the app | NONE FOUND (no emulator or device configured in this environment) | — |
| CI gates, in order | `flutter pub get`, `flutter test`, `flutter build apk --release` | `.github/workflows/build-release.yml:97-115` |
| Commit style | one line, sentence case, imperative, no prefix required | `git log` |
| Commit examples | `fix expanses vs income bar (#10)` / `Bug in savings (#4)` | `git log` |

## 6. Baseline — recorded 2026-08-20

| Gate | Command | Result |
|---|---|---|
| Install | `flutter pub get` | clean, exits 0 |
| Analyze | `flutter analyze` | `No issues found!` |
| Unit tests | `flutter test` | `172` passed, 0 failed |
| Unit tests (ViewModel file) | `flutter test test/presentation/viewmodel/main_screen_viewmodel_test.dart` | `+27: All tests passed!` |
| Build | `flutter build apk --debug` | exits 0, `✓ Built build/app/outputs/flutter-apk/app-debug.apk` in ~60s |
| L10n codegen | `flutter gen-l10n` | exits 0 and produces no diff; generated files are in sync with the `.arb` files |

Environment note: `flutter build apk --debug` failed during planning with
`java.lang.IllegalArgumentException: 25.0.2` from
`org.jetbrains.kotlin.com.intellij.util.lang.JavaVersion.parse`, because the only JDK on this
machine was OpenJDK 25.0.2 and Gradle 8.14's bundled Kotlin compiler cannot parse that version
string. This was fixed **before** the plan was committed: Temurin JDK 17.0.20+8 was unpacked
into `~/.jdks/jdk-17.0.20+8` and Flutter was pointed at it with `flutter config --jdk-dir`. The
baseline above was recorded after that fix, and the build now matches CI, which uses Java 17
(`.github/workflows/build-release.yml:86`). Do not change the JDK setting and do not reinstall
anything; if `flutter build apk --debug` ever reports `IllegalArgumentException: 25.0.2` again,
the JDK setting was lost — that is a stop condition (§11 R12), not something to work around.

Known pre-existing failures:

1. `dart format --output=none --set-exit-if-changed lib test` reports 8 already-unformatted
   files: `lib/data/services/transaction_local_service.dart`,
   `lib/domain/usecase/get_non_recurring_balance_usecase.dart`, `lib/main.dart`,
   `lib/presentation/ui/widgets/chart/pie_chart.dart`,
   `test/data/repository/transaction_repository_impl_test.dart`,
   `test/fakes/fake_transaction_repository.dart`, `test/fakes/fake_transaction_service.dart`,
   `test/presentation/ui/utils/category_icon_test.dart`. Never run `dart format` across the
   whole repository — only on the paths a block's **Touches** list names.

A failure listed here is not caused by this plan: do not fix it, do not let it block a block (§11 R12).

Pre-existing uncommitted paths: None.
These paths are not yours: never stage them, never revert them. The final block expects to see
them in `git status`.

## 7. Architecture and style rules that bind this task

1. Layer order is `Service → Repository → UseCase → ViewModel → Widget`; a widget never reaches a repository or a database — `AGENTS.md:20-21`.
2. Domain models are immutable and implement `copyWith()`, `operator ==` and `hashCode` — `AGENTS.md:26`.
3. Never create code duplication, and never create the same string or variable more than once — `AGENTS.md:34-35`.
4. Money is stored as `int amountCents` and formatted with `formatMoney()` from `lib/presentation/ui/utils/money_formatter.dart` — `AGENTS.md:30`.
5. A widget used only inside its own file is named `_NameWidget` — `AGENTS.md:28`.
6. `MainTopBar` must remain a pure renderer: it must not query the database, read `DateTime.now()`, or inspect the cache — `docs/monthly-data-flow.md:49`.
7. `_computeSavingsCents()` implements a separate savings rule and must not be changed — `docs/monthly-data-flow.md:59`.
8. Enums are used for finite types; `Transaction.category` stores the enum's `.name` as a `String?` — `AGENTS.md:32`, `lib/domain/model/transaction.dart:7`.

NOTE: `AGENTS.md:50` says test names must be in Portuguese, `docs/test-map.md:24` says they must
be in English, and all 172 existing tests use English `should ...`. The code wins: write English
test names. BLOCK 3 corrects `AGENTS.md:50`.

## 8. Security invariants

No security documentation found in this repository. Baseline invariants apply: never log or
commit secrets; never interpolate untrusted input into SQL, HTML, shell, or file paths;
never remove or bypass an existing authentication or authorization check; never widen a CORS,
cookie, or permission setting.

## 9. Quality bars

Violating any of these is a defect even when the tests pass.

- Do not add a `GetExpensesByCategoryUseCase`, a repository method, or a second SQLite query. The recurring-visibility rule lives only in `MainScreenViewModel._visibleItemsForMonth()`; a second implementation of it is a defect.
- Do not write a money-formatting helper. `formatMoney()` in `lib/presentation/ui/utils/money_formatter.dart` is the only one.
- Do not write `Color(0xFF...)` inside `lib/presentation/ui/widgets/chart/` or `lib/presentation/ui/screens/chart_screen.dart`. Every color comes from `lib/presentation/ui/theme/app_colors.dart`.
- Do not copy the body of `_MonthSelector` into `chart_screen.dart`. BLOCK 6 extracts it to a shared widget; both call sites use that one widget.
- Do not add English (or any other) hard-coded user-facing strings. Every visible string comes from `AppLocalizations`.
- Do not add colors, labels, or a resolver for `IncomeCategory`. The chart is expenses only; unused code is dead code.
- Do not add a `ChartViewModel`, a chart-specific `Command`, or a provider. `ChartScreen` is a pure renderer receiving plain parameters, like `MainTopBar`.
- Do not make the palette, the pie radius, the touch radius, or the legend layout configurable. There is exactly one caller.
- Do not add a `SystemChrome.setPreferredOrientations` call. Orientation is already unlocked and must stay that way.
- When "avoid duplication" and "avoid over-engineering" conflict, choose the smaller diff: duplicate once, extract on the third occurrence.

## 10. Test obligations

| Kind | Required | Why | Location | Command |
|---|---|---|---|---|
| Model unit | yes | new immutable value object `CategoryTotal` | `test/domain/model/category_total_test.dart` | `flutter test test/domain/model/category_total_test.dart` |
| ViewModel unit | yes | new aggregation logic inside `_filterAndComputeTotals()` and new clearing in `_clearSelectedMonthData()` | `test/presentation/viewmodel/main_screen_viewmodel_test.dart` | `flutter test test/presentation/viewmodel/main_screen_viewmodel_test.dart` |
| UI utility unit | yes | new exhaustive enum mapping and new `String?` resolvers | `test/presentation/ui/utils/category_color_test.dart`, `test/presentation/ui/utils/category_mapper_test.dart` | `flutter test test/presentation/ui/utils/` |
| Widget | yes | new rendering widgets with computed percentages and callbacks | `test/presentation/ui/widgets/chart/pie_chart_test.dart`, `test/presentation/ui/screens/chart_screen_test.dart` | `flutter test test/presentation/ui/widgets/ test/presentation/ui/screens/` |
| MainScreen widget | no | the repository has no `MainScreen` widget-test harness (`docs/test-map.md:22` records this as gap 3), and building one would duplicate the 60-line mock setup of `main_screen_viewmodel_test.dart`, which `AGENTS.md:34` forbids. The orientation branch is covered by `chart_screen_test.dart` plus the §2 `grep` check. | — | — |
| Integration | no | no new cross-module boundary; no new service, repository, or SQL | — | — |
| E2E | no | the project has none | — | — |
| Manual smoke | yes, by the human | device rotation in light and dark themes, and month change while in landscape, cannot be automated here | — | reported by the final block, not executed |

Follow the existing test style at `test/presentation/viewmodel/main_screen_viewmodel_test.dart`
for ViewModel tests, at `test/presentation/ui/utils/category_icon_test.dart` for utility tests,
and at `test/presentation/ui/widgets/main_top_bar_test.dart` for widget tests.

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
is not `chart`, stop (R12). Never leave, hide or rewrite the branch's work: no
`git checkout chart`, `git switch`, `git merge`, `git rebase`, `git reset`, `git stash`,
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
| 1 | Add the three chart localization keys | `PLAN/01-l10n-keys.md` | DONE |
| 2 | Add the `CategoryTotal` value object | `PLAN/02-category-total-model.md` | DONE |
| 3 | Aggregate expenses by category in the ViewModel | `PLAN/03-viewmodel-aggregation.md` | DONE |
| 4 | Add category colors and their resolver | `PLAN/04-category-colors.md` | DONE |
| 5 | Add the category label resolver | `PLAN/05-category-label-resolver.md` | DONE |
| 6 | Extract `MonthSelector` and delete the chart button | `PLAN/06-month-selector-extraction.md` | TODO |
| 7 | Make the pie chart data-driven | `PLAN/07-data-driven-pie-chart.md` | TODO |
| 8 | Rewrite `ChartScreen` as the landscape content | `PLAN/08-chart-screen.md` | TODO |
| 9 | Choose the content by orientation in `MainScreen` | `PLAN/09-main-screen-orientation.md` | TODO |
| 10 | Verify everything and remove the plan | `PLAN/10-cleanup.md` | TODO |

Statuses: `TODO` → `DONE`, or `BLOCKED` (see §11 R12).

## 13. Blocks

- `PLAN/01-l10n-keys.md`
- `PLAN/02-category-total-model.md`
- `PLAN/03-viewmodel-aggregation.md`
- `PLAN/04-category-colors.md`
- `PLAN/05-category-label-resolver.md`
- `PLAN/06-month-selector-extraction.md`
- `PLAN/07-data-driven-pie-chart.md`
- `PLAN/08-chart-screen.md`
- `PLAN/09-main-screen-orientation.md`
- `PLAN/10-cleanup.md`

## Blocked
