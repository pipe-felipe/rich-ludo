import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rich_ludo/data/services/transaction_local_service.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/main.dart' as app;
import 'package:rich_ludo/presentation/ui/widgets/transaction_card.dart';

/// E2E coverage for editing an existing transaction: tapping the transaction card opens
/// the dialog pre-filled with the stored values, a one-off edit writes the
/// new amount and notes, a recurring edit asks for its scope through the
/// four-option dialog, and turning the Repete switch off leaves the
/// "this month and previous" scope greyed out and non-tappable.
///
/// Run on a device or emulator:
///   flutter test integration_test/edit_transaction_test.dart -d `<device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final service = TransactionLocalService();
  final now = DateTime.now();

  Future<void> seedOneOff() async {
    await service.deleteAll();
    await service.insertAll([
      Transaction(
        amountCents: 5000,
        type: TransactionType.expense,
        category: 'food',
        description: 'Almoço',
        humanDate: '2026-08-04',
        targetMonth: now.month,
        targetYear: now.year,
      ),
    ]);
  }

  Future<void> seedRecurring() async {
    await service.deleteAll();
    await service.insertAll([
      Transaction(
        amountCents: 10000,
        type: TransactionType.expense,
        category: 'recurring',
        description: 'Aluguel',
        humanDate: '2026-08-01',
        isRecurring: true,
        targetMonth: now.month,
        targetYear: now.year,
      ),
    ]);
  }

  Future<void> startApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  Future<void> openEditDialog(WidgetTester tester) async {
    await tester.tap(find.byType(TransactionCard));
    await tester.pumpAndSettle();
  }

  Future<void> enterAmount(WidgetTester tester, String amount) async {
    await tester.enterText(find.widgetWithText(TextField, 'R\$ Valor'), amount);
    await tester.pump();
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
  }

  Future<void> goToNextMonth(WidgetTester tester) async {
    await tester.flingFrom(
      tester.getCenter(find.byType(app.RichLudoApp)),
      const Offset(-400, 0),
      1000,
    );
    await tester.pumpAndSettle();
  }

  group('Edit transaction', () {
    testWidgets(
      'tapping the card body opens the edit dialog without the pencil button',
      (tester) async {
        await seedOneOff();
        await startApp(tester);

        expect(find.byIcon(Icons.edit), findsNothing);
        expect(find.byIcon(Icons.delete), findsOneWidget);

        await openEditDialog(tester);

        expect(find.widgetWithText(TextField, '50.00'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Almoço'), findsOneWidget);
      },
    );

    testWidgets(
      'editing a one-off transaction writes the new amount and notes',
      (tester) async {
        await seedOneOff();
        await startApp(tester);

        await openEditDialog(tester);
        expect(find.widgetWithText(TextField, '50.00'), findsOneWidget);

        await enterAmount(tester, '75');
        await tester.enterText(
          find.widgetWithText(TextField, 'Notas'),
          'Jantar',
        );
        await tester.pump();
        await submit(tester);

        expect(find.text('-R\$75.00'), findsOneWidget);
        expect(find.text('Jantar'), findsOneWidget);
        expect(find.text('-R\$50.00'), findsNothing);
      },
    );

    testWidgets(
      'editing a recurring transaction for all months changes every month',
      (tester) async {
        await seedRecurring();
        await startApp(tester);

        await openEditDialog(tester);
        await enterAmount(tester, '120');
        await submit(tester);
        await tester.tap(find.text('Todos os meses'));
        await tester.pumpAndSettle();

        expect(find.text('-R\$120.00'), findsOneWidget);

        await goToNextMonth(tester);

        expect(find.text('-R\$120.00'), findsOneWidget);
      },
    );

    testWidgets(
      'editing a recurring transaction for this month leaves the next month alone',
      (tester) async {
        await seedRecurring();
        await startApp(tester);

        await openEditDialog(tester);
        await enterAmount(tester, '250');
        await submit(tester);
        await tester.tap(find.text('Apenas este mês'));
        await tester.pumpAndSettle();

        expect(find.text('-R\$250.00'), findsOneWidget);
        expect(find.text('-R\$100.00'), findsNothing);

        await goToNextMonth(tester);

        expect(find.text('-R\$100.00'), findsOneWidget);
        expect(find.text('-R\$250.00'), findsNothing);
      },
    );

    testWidgets(
      'turning Repete off leaves this month and previous unreachable',
      (tester) async {
        await seedRecurring();
        await startApp(tester);

        await openEditDialog(tester);
        await tester.tap(find.byType(Switch));
        await tester.pump();
        await submit(tester);

        expect(find.text('Editar recorrente'), findsOneWidget);

        await tester.tap(find.text('Este mês e anteriores'));
        await tester.pumpAndSettle();

        expect(find.text('Editar recorrente'), findsOneWidget);

        await tester.tap(find.text('Todos os meses'));
        await tester.pumpAndSettle();

        expect(find.text('Editar recorrente'), findsNothing);
      },
    );
  });
}
