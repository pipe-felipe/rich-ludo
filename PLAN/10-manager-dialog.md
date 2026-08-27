## BLOCK 10 — Add `CategoryManagerDialog`

**Depends on:** BLOCK 9 committed
**Touches:** `lib/presentation/ui/widgets/category_manager_dialog.dart` (NEW), `test/presentation/ui/widgets/category_manager_dialog_test.dart` (NEW)

### Goal
A dialog that creates a category from a name, an icon and a color, lists the user's categories
of its transaction type with a delete button each, shows why a create or a delete was refused,
and pops the new slug when a create succeeds.

### Context to read first
1. `lib/presentation/ui/widgets/recurring_delete_dialog.dart:1-80` — the dialog shape to mirror: a `static Future<T?> show(BuildContext context, ...)` wrapping `showDialog`, a `Dialog` with a rounded `RoundedRectangleBorder`, a `Padding` + `Column(mainAxisSize: MainAxisSize.min)` body, a `titleLarge` bold heading, and a trailing `FilledButton.tonal` labelled `l10n.formCloseButtonDescription`.
2. `lib/presentation/viewmodel/category_viewmodel.dart` — the whole file; `categoriesFor(TransactionType)`, and the `create` and `delete` commands whose `result` this dialog reads after `execute`.
3. `lib/domain/usecase/create_custom_category_usecase.dart` and `lib/domain/usecase/delete_custom_category_usecase.dart` — `CategoryValidationError`, `CategoryValidationException`, `CategoryInUseException` and `CreateCustomCategoryUseCase.maxNameLength`.
4. `lib/presentation/ui/utils/category_icon.dart` — `customCategoryIcons` and `resolveCustomCategoryIcon`; `lib/presentation/ui/theme/app_colors.dart` — `CategoryPiColors.customPalette`.
5. `test/presentation/ui/screens/chart_screen_test.dart:1-42` — the widget-test harness to mirror: `tester.view.physicalSize` with `addTearDown(tester.view.resetPhysicalSize)`, and a `MaterialApp` carrying `AppTheme.lightTheme()`, `AppLocalizations.localizationsDelegates`, `AppLocalizations.supportedLocales` and `locale: const Locale('pt')`.
6. §8 Security invariants — the name typed here is user input; it reaches SQLite only through the model and the mapper, never through a SQL string.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/presentation/ui/widgets/category_manager_dialog.dart` with exactly this content:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:provider/provider.dart';

   import '../../../domain/model/custom_category.dart';
   import '../../../domain/model/transaction_type.dart';
   import '../../../domain/usecase/create_custom_category_usecase.dart';
   import '../../../domain/usecase/delete_custom_category_usecase.dart';
   import '../../../l10n/app_localizations.dart';
   import '../../../utils/result.dart';
   import '../../viewmodel/category_viewmodel.dart';
   import '../theme/app_colors.dart';
   import '../utils/category_icon.dart';

   /// Creates and deletes the categories the user owns for one [TransactionType].
   ///
   /// Deleting is refused while a transaction still carries the category, so a
   /// stored transaction can never end up labelled with a category the user can
   /// no longer see.
   class CategoryManagerDialog extends StatefulWidget {
     final TransactionType transactionType;

     const CategoryManagerDialog({super.key, required this.transactionType});

     /// Returns the slug of the category created in this session, or `null` when
     /// the dialog was closed without creating one.
     static Future<String?> show(BuildContext context, TransactionType type) {
       return showDialog<String>(
         context: context,
         builder: (_) => CategoryManagerDialog(transactionType: type),
       );
     }

     @override
     State<CategoryManagerDialog> createState() => _CategoryManagerDialogState();
   }

   class _CategoryManagerDialogState extends State<CategoryManagerDialog> {
     final TextEditingController _nameController = TextEditingController();
     int _iconIndex = 0;
     int _colorIndex = 0;
     String? _formErrorText;
     String? _deleteErrorText;

     @override
     void dispose() {
       _nameController.dispose();
       super.dispose();
     }

     @override
     Widget build(BuildContext context) {
       final l10n = AppLocalizations.of(context)!;
       final theme = Theme.of(context);
       final viewModel = context.watch<CategoryViewModel>();
       final categories = viewModel.categoriesFor(widget.transactionType);

       return Dialog(
         insetPadding: const EdgeInsets.symmetric(horizontal: 25),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: SingleChildScrollView(
             child: Column(
               mainAxisSize: MainAxisSize.min,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   l10n.categoryManagerTitle,
                   style: theme.textTheme.titleLarge?.copyWith(
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 12),
                 TextField(
                   controller: _nameController,
                   maxLength: CreateCustomCategoryUseCase.maxNameLength,
                   decoration: InputDecoration(
                     labelText: l10n.categoryNameLabel,
                     border: const OutlineInputBorder(),
                     errorText: _formErrorText,
                   ),
                 ),
                 Text(l10n.categoryIconLabel, style: theme.textTheme.labelMedium),
                 const SizedBox(height: 6),
                 _IconPicker(
                   selectedIndex: _iconIndex,
                   onSelected: (index) => setState(() => _iconIndex = index),
                 ),
                 const SizedBox(height: 12),
                 Text(l10n.categoryColorLabel, style: theme.textTheme.labelMedium),
                 const SizedBox(height: 6),
                 _ColorPicker(
                   selectedIndex: _colorIndex,
                   onSelected: (index) => setState(() => _colorIndex = index),
                 ),
                 const SizedBox(height: 12),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     FilledButton.tonal(
                       onPressed: () => Navigator.of(context).pop(),
                       child: Text(l10n.formCloseButtonDescription),
                     ),
                     const SizedBox(width: 8),
                     ElevatedButton(
                       onPressed: () => _onSave(viewModel, l10n),
                       child: Text(l10n.categorySave),
                     ),
                   ],
                 ),
                 const Divider(height: 24),
                 Text(
                   l10n.categoryMineTitle,
                   style: theme.textTheme.titleSmall?.copyWith(
                     fontWeight: FontWeight.w600,
                   ),
                 ),
                 const SizedBox(height: 6),
                 if (categories.isEmpty)
                   Text(l10n.categoryEmpty, style: theme.textTheme.bodyMedium)
                 else
                   ...categories.map(
                     (category) => _CategoryRow(
                       category: category,
                       onDelete: () => _onDelete(viewModel, category, l10n),
                     ),
                   ),
                 if (_deleteErrorText != null) ...[
                   const SizedBox(height: 8),
                   Text(
                     _deleteErrorText!,
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: theme.colorScheme.error,
                     ),
                   ),
                 ],
               ],
             ),
           ),
         ),
       );
     }

     Future<void> _onSave(
       CategoryViewModel viewModel,
       AppLocalizations l10n,
     ) async {
       final draft = CustomCategory.draft(
         name: _nameController.text,
         type: widget.transactionType,
         iconCodePoint: customCategoryIcons[_iconIndex].codePoint,
         colorValue: CategoryPiColors.customPalette[_colorIndex].toARGB32(),
       );

       await viewModel.create.execute(draft);

       if (!mounted) return;

       final result = viewModel.create.result;
       if (result == null) return;

       switch (result) {
         case Ok<int>():
           Navigator.of(context).pop(draft.slug);
         case Error<int>(:final error):
           setState(() => _formErrorText = _createErrorText(error, l10n));
       }
     }

     Future<void> _onDelete(
       CategoryViewModel viewModel,
       CustomCategory category,
       AppLocalizations l10n,
     ) async {
       await viewModel.delete.execute(category);

       if (!mounted) return;

       final result = viewModel.delete.result;
       setState(() {
         _deleteErrorText = switch (result) {
           Error<int>(:final error) when error is CategoryInUseException =>
             l10n.categoryDeleteInUse(error.transactionCount),
           Error<int>() => l10n.categoryErrorSaveFailed,
           _ => null,
         };
       });
     }

     String _createErrorText(Exception error, AppLocalizations l10n) {
       if (error is! CategoryValidationException) {
         return l10n.categoryErrorSaveFailed;
       }

       return switch (error.reason) {
         CategoryValidationError.emptyName => l10n.categoryErrorEmptyName,
         CategoryValidationError.nameTooLong => l10n.categoryErrorNameTooLong,
         CategoryValidationError.duplicateName => l10n.categoryErrorDuplicateName,
       };
     }
   }

   class _IconPicker extends StatelessWidget {
     final int selectedIndex;
     final void Function(int) onSelected;

     const _IconPicker({required this.selectedIndex, required this.onSelected});

     @override
     Widget build(BuildContext context) {
       final colorScheme = Theme.of(context).colorScheme;

       return Wrap(
         spacing: 6,
         runSpacing: 6,
         children: List.generate(customCategoryIcons.length, (index) {
           final isSelected = index == selectedIndex;

           return InkWell(
             onTap: () => onSelected(index),
             borderRadius: BorderRadius.circular(8),
             child: Container(
               width: 40,
               height: 40,
               decoration: BoxDecoration(
                 color: isSelected
                     ? colorScheme.primaryContainer
                     : Colors.transparent,
                 border: Border.all(color: colorScheme.outline),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Icon(customCategoryIcons[index], size: 20),
             ),
           );
         }),
       );
     }
   }

   class _ColorPicker extends StatelessWidget {
     final int selectedIndex;
     final void Function(int) onSelected;

     const _ColorPicker({required this.selectedIndex, required this.onSelected});

     @override
     Widget build(BuildContext context) {
       final colorScheme = Theme.of(context).colorScheme;

       return Wrap(
         spacing: 8,
         runSpacing: 8,
         children: List.generate(CategoryPiColors.customPalette.length, (index) {
           final isSelected = index == selectedIndex;

           return InkWell(
             onTap: () => onSelected(index),
             customBorder: const CircleBorder(),
             child: Container(
               width: 32,
               height: 32,
               decoration: BoxDecoration(
                 color: CategoryPiColors.customPalette[index],
                 shape: BoxShape.circle,
                 border: Border.all(
                   color: isSelected ? colorScheme.onSurface : Colors.transparent,
                   width: 3,
                 ),
               ),
             ),
           );
         }),
       );
     }
   }

   class _CategoryRow extends StatelessWidget {
     final CustomCategory category;
     final VoidCallback onDelete;

     const _CategoryRow({required this.category, required this.onDelete});

     @override
     Widget build(BuildContext context) {
       final l10n = AppLocalizations.of(context)!;

       return Row(
         children: [
           Icon(
             resolveCustomCategoryIcon(category.iconCodePoint),
             size: 20,
             color: Color(category.colorValue),
           ),
           const SizedBox(width: 8),
           Expanded(child: Text(category.name, overflow: TextOverflow.ellipsis)),
           IconButton(
             onPressed: onDelete,
             tooltip: l10n.categoryDeleteTooltip,
             icon: const Icon(Icons.delete_outline),
           ),
         ],
       );
     }
   }
   ```
2. Create `test/presentation/ui/widgets/category_manager_dialog_test.dart` with exactly these 6 tests:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:provider/provider.dart';
   import 'package:rich_ludo/domain/model/custom_category.dart';
   import 'package:rich_ludo/domain/model/transaction_type.dart';
   import 'package:rich_ludo/domain/usecase/create_custom_category_usecase.dart';
   import 'package:rich_ludo/domain/usecase/delete_custom_category_usecase.dart';
   import 'package:rich_ludo/domain/usecase/get_custom_categories_usecase.dart';
   import 'package:rich_ludo/l10n/app_localizations.dart';
   import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
   import 'package:rich_ludo/presentation/ui/widgets/category_manager_dialog.dart';
   import 'package:rich_ludo/presentation/viewmodel/category_viewmodel.dart';
   import 'package:rich_ludo/utils/result.dart';

   class MockGetCustomCategoriesUseCase extends Mock
       implements GetCustomCategoriesUseCase {}

   class MockCreateCustomCategoryUseCase extends Mock
       implements CreateCustomCategoryUseCase {}

   class MockDeleteCustomCategoryUseCase extends Mock
       implements DeleteCustomCategoryUseCase {}

   class FakeCustomCategory extends Fake implements CustomCategory {}

   void main() {
     late MockGetCustomCategoriesUseCase mockGetCustomCategoriesUseCase;
     late MockCreateCustomCategoryUseCase mockCreateCustomCategoryUseCase;
     late MockDeleteCustomCategoryUseCase mockDeleteCustomCategoryUseCase;
     late CategoryViewModel viewModel;
     String? returnedSlug;

     const expenseCategory = CustomCategory(
       id: 1,
       slug: 'custom_mercado',
       name: 'Mercado',
       type: TransactionType.expense,
       iconCodePoint: 0xe59c,
       colorValue: 0xFFC62828,
     );

     const incomeCategory = CustomCategory(
       id: 2,
       slug: 'custom_bonus',
       name: 'Bonus',
       type: TransactionType.income,
       iconCodePoint: 0xe553,
       colorValue: 0xFF2E7D32,
     );

     setUpAll(() {
       registerFallbackValue(FakeCustomCategory());
     });

     setUp(() {
       returnedSlug = null;
       mockGetCustomCategoriesUseCase = MockGetCustomCategoriesUseCase();
       mockCreateCustomCategoryUseCase = MockCreateCustomCategoryUseCase();
       mockDeleteCustomCategoryUseCase = MockDeleteCustomCategoryUseCase();
     });

     tearDown(() => viewModel.dispose());

     // The provider sits above MaterialApp so the dialog route, which the root
     // navigator pushes, still finds the CategoryViewModel.
     Future<void> openDialog(
       WidgetTester tester,
       List<CustomCategory> stored,
     ) async {
       when(
         () => mockGetCustomCategoriesUseCase(),
       ).thenAnswer((_) async => Result.ok(stored));

       viewModel = CategoryViewModel(
         getCustomCategoriesUseCase: mockGetCustomCategoriesUseCase,
         createCustomCategoryUseCase: mockCreateCustomCategoryUseCase,
         deleteCustomCategoryUseCase: mockDeleteCustomCategoryUseCase,
       );

       tester.view.physicalSize = const Size(1200, 2400);
       tester.view.devicePixelRatio = 1.0;
       addTearDown(tester.view.resetPhysicalSize);
       addTearDown(tester.view.resetDevicePixelRatio);

       await tester.pumpWidget(
         ChangeNotifierProvider<CategoryViewModel>.value(
           value: viewModel,
           child: MaterialApp(
             theme: AppTheme.lightTheme(),
             localizationsDelegates: AppLocalizations.localizationsDelegates,
             supportedLocales: AppLocalizations.supportedLocales,
             locale: const Locale('pt'),
             home: Builder(
               builder: (context) => Scaffold(
                 body: Center(
                   child: ElevatedButton(
                     onPressed: () async {
                       returnedSlug = await CategoryManagerDialog.show(
                         context,
                         TransactionType.expense,
                       );
                     },
                     child: const Text('abrir'),
                   ),
                 ),
               ),
             ),
           ),
         ),
       );

       await tester.pumpAndSettle();
       await tester.tap(find.text('abrir'));
       await tester.pumpAndSettle();
     }

     group('CategoryManagerDialog', () {
       testWidgets('should render one row per category of the dialog type', (
         tester,
       ) async {
         await openDialog(tester, const [expenseCategory, incomeCategory]);

         expect(find.text('Mercado'), findsOneWidget);
         expect(find.text('Bonus'), findsNothing);
         expect(find.byIcon(Icons.delete_outline), findsOneWidget);
       });

       testWidgets('should render the empty message when the type has none', (
         tester,
       ) async {
         await openDialog(tester, const [incomeCategory]);

         expect(
           find.text('Você ainda não criou nenhuma categoria'),
           findsOneWidget,
         );
         expect(find.byIcon(Icons.delete_outline), findsNothing);
       });

       testWidgets('should offer every icon and every color of the pickers', (
         tester,
       ) async {
         await openDialog(tester, const []);

         expect(find.byType(Wrap), findsNWidgets(2));
       });

       testWidgets('should show the duplicate message when creating fails', (
         tester,
       ) async {
         when(() => mockCreateCustomCategoryUseCase(any())).thenAnswer(
           (_) async => const Result<int>.error(
             CategoryValidationException(CategoryValidationError.duplicateName),
           ),
         );
         await openDialog(tester, const []);

         await tester.enterText(find.byType(TextField), 'Mercado');
         await tester.tap(find.text('Salvar'));
         await tester.pumpAndSettle();

         expect(
           find.text('Já existe uma categoria com esse nome'),
           findsOneWidget,
         );
         expect(returnedSlug, isNull);
       });

       testWidgets('should pop the new slug when creating succeeds', (
         tester,
       ) async {
         when(
           () => mockCreateCustomCategoryUseCase(any()),
         ).thenAnswer((_) async => const Result.ok(3));
         await openDialog(tester, const []);

         await tester.enterText(find.byType(TextField), 'Mercado');
         await tester.tap(find.text('Salvar'));
         await tester.pumpAndSettle();

         expect(find.byType(CategoryManagerDialog), findsNothing);
         expect(returnedSlug, equals('custom_mercado'));
       });

       testWidgets('should show the in-use count when deleting is refused', (
         tester,
       ) async {
         when(
           () => mockDeleteCustomCategoryUseCase(any()),
         ).thenAnswer((_) async => const Result<int>.error(CategoryInUseException(4)));
         await openDialog(tester, const [expenseCategory]);

         await tester.tap(find.byIcon(Icons.delete_outline));
         await tester.pumpAndSettle();

         expect(
           find.text('4 transações usam esta categoria. Não é possível excluir.'),
           findsOneWidget,
         );
         expect(find.text('Mercado'), findsOneWidget);
       });
     });
   }
   ```
3. Run the §5 `write-only` formatter on the Touches paths only:
   ```
   dart format lib/presentation/ui/widgets/category_manager_dialog.dart test/presentation/ui/widgets/category_manager_dialog_test.dart
   ```

### Do not
- Do not open a second confirmation dialog before deleting. A delete only ever succeeds when zero transactions carry the category, so nothing the user stored can be lost by a mis-tap; the refusal message is the guard.
- Do not add an edit or rename affordance to a row. §3 puts renaming out of scope.
- Do not call `showFloatingNotification`; the two inline error texts are this dialog's only error surface.
- Do not add a `CategoryFormController`, an `IconPickerController`, or a state class for the pickers (§9). `_CategoryManagerDialogState` holds `_iconIndex` and `_colorIndex` directly.
- Do not write `CategoryPiColors.customPalette[_colorIndex].value`; §9 requires `toARGB32()`.
- Do not wire this dialog into `transaction_dialog.dart` here — that is BLOCK 11.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/category_manager_dialog_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+6`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 293 tests (287 after BLOCK 9, plus 6).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/presentation/ui/widgets/category_manager_dialog.dart` and `test/presentation/ui/widgets/category_manager_dialog_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 10's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/category_manager_dialog.dart test/presentation/ui/widgets/category_manager_dialog_test.dart PLAN.md
   git commit -m "Add the category manager dialog"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.
