import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rich_ludo/data/services/transaction_local_service.dart';
import 'package:rich_ludo/domain/model/month_year.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/main.dart' as app;

/// E2E coverage for deleting a transaction: a one-off row is removed
/// immediately, and a recurring row asks which months to cover through the
/// same RecurringScopeDialog the edit flow uses — "Todos os meses" removes
/// every month, "Apenas este mês" leaves the other months untouched, and
/// "Este mês e futuros" ends the rule at the previous month.
///
/// Run on a device or emulator:
///   flutter test integration_test/delete_transaction_test.dart -d `<device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final service = TransactionLocalService();
  final now = DateTime.now();
  final currentMonth = MonthYear(now.month, now.year);
  final previousMonth = currentMonth.previous;

  Future<void> seedOneOff() async {
    await service.deleteAll();
    await service.insertAll([
      Transaction(
        amountCents: 5000,
        type: TransactionType.expense,
        category: 'food',
        description: 'Almoço',
        humanDate: '2026-08-04',
        targetMonth: currentMonth.month,
        targetYear: currentMonth.year,
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
        targetMonth: currentMonth.month,
        targetYear: currentMonth.year,
      ),
    ]);
  }

  Future<void> seedRecurringStartingLastMonth() async {
    await service.deleteAll();
    await service.insertAll([
      Transaction(
        amountCents: 10000,
        type: TransactionType.expense,
        category: 'recurring',
        description: 'Aluguel',
        humanDate: '2026-08-01',
        isRecurring: true,
        targetMonth: previousMonth.month,
        targetYear: previousMonth.year,
      ),
    ]);
  }

  Future<void> startApp(WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
  }

  Future<void> openDeleteDialog(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
  }

  Future<void> goToPreviousMonth(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_left));
    await tester.pumpAndSettle();
  }

  Future<void> goToNextMonth(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
    await tester.pumpAndSettle();
  }

  group('Delete transaction', () {
    testWidgets('deleting a one-off transaction removes it from the list', (
      tester,
    ) async {
      await seedOneOff();
      await startApp(tester);

      expect(find.text('Almoço'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.text('Almoço'), findsNothing);
      expect(find.text('Sem transações para mostrar'), findsOneWidget);
    });

    testWidgets(
      'deleting a recurring transaction for all months removes it from every month',
      (tester) async {
        await seedRecurring();
        await startApp(tester);

        await openDeleteDialog(tester);
        expect(find.text('Deletar recorrente'), findsOneWidget);

        await tester.tap(find.text('Todos os meses'));
        await tester.pumpAndSettle();

        expect(find.text('Aluguel'), findsNothing);
        expect(find.text('Sem transações para mostrar'), findsOneWidget);

        await goToPreviousMonth(tester);

        expect(find.text('Aluguel'), findsNothing);
        expect(find.text('Sem transações para mostrar'), findsOneWidget);
      },
    );

    testWidgets(
      'deleting a recurring transaction for this month leaves other months alone',
      (tester) async {
        await seedRecurring();
        await startApp(tester);

        await openDeleteDialog(tester);
        await tester.tap(find.text('Apenas este mês'));
        await tester.pumpAndSettle();

        expect(find.text('Aluguel'), findsNothing);
        expect(find.text('Sem transações para mostrar'), findsOneWidget);

        await goToNextMonth(tester);

        expect(find.text('Aluguel'), findsOneWidget);
      },
    );

    testWidgets(
      'deleting a recurring transaction for this month and future ends the rule at the previous month',
      (tester) async {
        await seedRecurringStartingLastMonth();
        await startApp(tester);

        expect(find.text('Aluguel'), findsOneWidget);

        await openDeleteDialog(tester);
        await tester.tap(find.text('Este mês e futuros'));
        await tester.pumpAndSettle();

        expect(find.text('Aluguel'), findsNothing);
        expect(find.text('Sem transações para mostrar'), findsOneWidget);

        await goToPreviousMonth(tester);

        expect(find.text('Aluguel'), findsOneWidget);
      },
    );
  });
}
