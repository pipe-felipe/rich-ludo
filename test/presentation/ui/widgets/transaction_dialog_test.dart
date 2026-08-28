import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/create_custom_category_usecase.dart';
import 'package:rich_ludo/domain/usecase/delete_custom_category_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_custom_categories_usecase.dart';
import 'package:rich_ludo/domain/usecase/make_transaction_usecase.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
import 'package:rich_ludo/presentation/ui/widgets/category_manager_dialog.dart';
import 'package:rich_ludo/presentation/ui/widgets/transaction_dialog.dart';
import 'package:rich_ludo/presentation/viewmodel/category_viewmodel.dart';
import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';
import 'package:rich_ludo/utils/result.dart';

class MockGetCustomCategoriesUseCase extends Mock
    implements GetCustomCategoriesUseCase {}

class MockCreateCustomCategoryUseCase extends Mock
    implements CreateCustomCategoryUseCase {}

class MockDeleteCustomCategoryUseCase extends Mock
    implements DeleteCustomCategoryUseCase {}

class MockMakeTransactionUseCase extends Mock
    implements MakeTransactionUseCase {}

class FakeCustomCategory extends Fake implements CustomCategory {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late CategoryViewModel categoryViewModel;
  late TransactionFormViewModel formViewModel;

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
    registerFallbackValue(FakeTransaction());
  });

  tearDown(() {
    categoryViewModel.dispose();
    formViewModel.dispose();
  });

  Future<void> openTransactionDialog(
    WidgetTester tester,
    List<CustomCategory> stored,
  ) async {
    final mockGet = MockGetCustomCategoriesUseCase();
    when(() => mockGet()).thenAnswer((_) async => Result.ok(stored));

    categoryViewModel = CategoryViewModel(
      getCustomCategoriesUseCase: mockGet,
      createCustomCategoryUseCase: MockCreateCustomCategoryUseCase(),
      deleteCustomCategoryUseCase: MockDeleteCustomCategoryUseCase(),
    );
    formViewModel = TransactionFormViewModel(
      makeTransactionUseCase: MockMakeTransactionUseCase(),
    );

    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CategoryViewModel>.value(
            value: categoryViewModel,
          ),
          ChangeNotifierProvider<TransactionFormViewModel>.value(
            value: formViewModel,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: const Scaffold(
            body: TransactionDialog(selectedMonth: 8, selectedYear: 2026),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
  }

  group('TransactionDialog category dropdown', () {
    testWidgets('should list a user-created expense category', (tester) async {
      await openTransactionDialog(tester, const [expenseCategory]);

      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Mercado'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Comida'),
        findsOneWidget,
      );
    });

    testWidgets('should not list a user-created income category', (
      tester,
    ) async {
      await openTransactionDialog(tester, const [
        expenseCategory,
        incomeCategory,
      ]);

      expect(
        find.widgetWithText(DropdownMenuItem<String>, 'Bonus'),
        findsNothing,
      );
    });

    testWidgets('should open the category manager from the last entry', (
      tester,
    ) async {
      await openTransactionDialog(tester, const []);

      await tester.tap(
        find.widgetWithText(DropdownMenuItem<String>, 'Nova categoria'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategoryManagerDialog), findsOneWidget);
    });
  });
}
