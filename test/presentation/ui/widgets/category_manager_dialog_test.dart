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
      when(() => mockDeleteCustomCategoryUseCase(any())).thenAnswer(
        (_) async => const Result<int>.error(CategoryInUseException(4)),
      );
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
