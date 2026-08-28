import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rich_ludo/data/services/category_local_service.dart';
import 'package:rich_ludo/data/services/transaction_local_service.dart';
import 'package:rich_ludo/main.dart' as app;
import 'package:rich_ludo/presentation/ui/widgets/category_manager_dialog.dart';

/// E2E coverage for user-created categories: creating one from the
/// transaction dialog's "New category" entry, seeing it selected and
/// rendered on the saved transaction and on the landscape chart, and the
/// delete-refused / delete-allowed rule enforced against a real transaction.
///
/// Run on a device or emulator:
///   flutter test integration_test/custom_categories_test.dart -d `<device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final transactionService = TransactionLocalService();
  final categoryService = CategoryLocalService();

  // Both tables persist on the real device between tests, so every test
  // starts from an empty slate the same way chart_orientation_test.dart
  // resets transactions before seeding its own fixture.
  Future<void> resetData() async {
    await transactionService.deleteAll();

    final existing = await categoryService.getAllCategories();
    for (final category in existing.asOk.value) {
      await categoryService.deleteCategory(category.id);
    }
  }

  Future<void> startApp(WidgetTester tester) async {
    await resetData();
    app.main();
    await tester.pumpAndSettle();
  }

  void setLandscape(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openTransactionDialog(WidgetTester tester) async {
    await tester.tap(find.image(const AssetImage('assets/icons/add-item.png')));
    await tester.pumpAndSettle();
  }

  // Opens the category dropdown and picks its trailing "New category" entry,
  // which is how CategoryManagerDialog is reached in the running app.
  Future<void> openCategoryManager(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DropdownMenuItem<String>, 'Nova categoria'),
    );
    await tester.pumpAndSettle();
  }

  // Creates a category with the default icon and color (first entry of each
  // picker) and leaves it selected in the transaction dialog underneath.
  Future<void> createCustomCategory(WidgetTester tester, String name) async {
    await openCategoryManager(tester);
    // TransactionDialog stays mounted underneath, so scope to the dialog on
    // top instead of find.byType(TextField), which would also match its
    // quantity and notes fields.
    await tester.enterText(
      find.descendant(
        of: find.byType(CategoryManagerDialog),
        matching: find.byType(TextField),
      ),
      name,
    );
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  Future<void> submitTransaction(
    WidgetTester tester,
    String amount, {
    String notes = '',
  }) async {
    await tester.enterText(find.widgetWithText(TextField, 'R\$ Valor'), amount);
    if (notes.isNotEmpty) {
      await tester.enterText(find.widgetWithText(TextField, 'Notas'), notes);
    }
    // The submit button only enables once TransactionFormViewModel notifies
    // its rebuild, so give the tree a frame before relying on onPressed.
    await tester.pump();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
  }

  group('Custom categories', () {
    testWidgets(
      'creating a category from the transaction dialog selects it and the '
      'saved transaction shows its name and icon',
      (tester) async {
        await startApp(tester);
        await openTransactionDialog(tester);
        await createCustomCategory(tester, 'Mercado');

        // The new category is now the value shown on the closed dropdown.
        expect(find.text('Mercado'), findsOneWidget);

        await submitTransaction(tester, '50', notes: 'Mercado run');

        expect(find.text('Mercado run'), findsOneWidget);
        expect(find.text('-R\$50.00'), findsOneWidget);
        // Default icon (first entry of the picker) resolved back correctly.
        expect(find.byIcon(Icons.label), findsOneWidget);
      },
    );

    testWidgets(
      'a transaction using a custom category renders its label and color '
      'in the landscape chart',
      (tester) async {
        await startApp(tester);
        await openTransactionDialog(tester);
        await createCustomCategory(tester, 'Mercado');
        await submitTransaction(tester, '50');

        setLandscape(tester);
        await tester.pumpAndSettle();

        expect(find.text('Mercado'), findsOneWidget);
        expect(find.text('R\$ 50.00  (100%)'), findsOneWidget);
        expect(find.text('R\$ 50.00'), findsOneWidget);
        // Default color (first entry of the picker) resolved back correctly.
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    const Color(0xFFC62828),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deleting a custom category is refused while a transaction still uses it',
      (tester) async {
        await startApp(tester);
        await openTransactionDialog(tester);
        await createCustomCategory(tester, 'Mercado');
        await submitTransaction(tester, '50');

        await openTransactionDialog(tester);
        await openCategoryManager(tester);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        final managerDialog = find.byType(CategoryManagerDialog);
        expect(
          find.descendant(
            of: managerDialog,
            matching: find.text(
              '1 transações usam esta categoria. Não é possível excluir.',
            ),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(of: managerDialog, matching: find.text('Mercado')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deleting a custom category succeeds once no transaction uses it',
      (tester) async {
        await startApp(tester);
        await openTransactionDialog(tester);
        await createCustomCategory(tester, 'Mercado');
        await submitTransaction(tester, '50');

        // Free the category by deleting the transaction that used it.
        await tester.tap(find.byIcon(Icons.delete));
        await tester.pumpAndSettle();

        expect(find.text('Sem transações para mostrar'), findsOneWidget);

        await openTransactionDialog(tester);
        // Select the category before deleting it, so the dropdown holds its
        // slug (instead of nothing chosen) when the category disappears.
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(DropdownMenuItem<String>, 'Mercado'),
        );
        await tester.pumpAndSettle();
        await openCategoryManager(tester);

        await tester.tap(find.byIcon(Icons.delete_outline));
        await tester.pumpAndSettle();

        final managerDialog = find.byType(CategoryManagerDialog);
        expect(
          find.descendant(of: managerDialog, matching: find.text('Mercado')),
          findsNothing,
        );
        expect(
          find.descendant(
            of: managerDialog,
            matching: find.text('Você ainda não criou nenhuma categoria'),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
