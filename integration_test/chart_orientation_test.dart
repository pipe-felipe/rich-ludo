import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rich_ludo/data/services/transaction_local_service.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/main.dart' as app;
import 'package:rich_ludo/presentation/ui/widgets/main_bottom_bar.dart';
import 'package:rich_ludo/presentation/ui/widgets/main_top_bar.dart';

/// E2E smoke of the orientation-driven chart, mirroring the manual emulator
/// session: portrait shows the transaction list, landscape shows the
/// expenses-by-category pie chart, and the month swipe works in landscape.
///
/// Run on a device or emulator:
///   flutter test integration_test/chart_orientation_test.dart -d `<device>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final service = TransactionLocalService();
  final now = DateTime.now();
  final nextMonth = DateTime(now.year, now.month + 1);

  // Deterministic seed: three expenses (50% / 30% / 20%) plus one income in
  // the current month, and one expense in the next month for the swipe check.
  Future<void> seed() async {
    await service.deleteAll();
    await service.insertAll([
      Transaction(
        amountCents: 100000,
        type: TransactionType.income,
        category: 'salary',
        description: 'Salário',
        humanDate: '2026-08-01',
        targetMonth: now.month,
        targetYear: now.year,
      ),
      Transaction(
        amountCents: 50000,
        type: TransactionType.expense,
        category: 'food',
        description: 'Mercado',
        humanDate: '2026-08-02',
        targetMonth: now.month,
        targetYear: now.year,
      ),
      Transaction(
        amountCents: 30000,
        type: TransactionType.expense,
        category: 'transport',
        description: 'Ônibus',
        humanDate: '2026-08-03',
        targetMonth: now.month,
        targetYear: now.year,
      ),
      Transaction(
        amountCents: 20000,
        type: TransactionType.expense,
        description: 'Livro',
        humanDate: '2026-08-04',
        targetMonth: now.month,
        targetYear: now.year,
      ),
      Transaction(
        amountCents: 70000,
        type: TransactionType.expense,
        category: 'gift',
        description: 'Aniversário',
        humanDate: '2026-09-01',
        targetMonth: nextMonth.month,
        targetYear: nextMonth.year,
      ),
    ]);
  }

  Future<void> startApp(WidgetTester tester) async {
    await seed();
    app.main();
    await tester.pumpAndSettle();
  }

  void setLandscape(WidgetTester tester) {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('MainScreen orientation', () {
    testWidgets('portrait shows the top bar and the transaction list', (
      tester,
    ) async {
      await startApp(tester);

      expect(find.byType(MainTopBar), findsOneWidget);
      expect(find.byType(MainBottomBar), findsOneWidget);

      expect(find.text('Salário'), findsOneWidget);
      expect(find.text('Mercado'), findsOneWidget);
      expect(find.text('Ônibus'), findsOneWidget);
      expect(find.text('-R\$500.00'), findsOneWidget);
      expect(find.text('R\$1000.00'), findsOneWidget);
    });

    testWidgets('landscape replaces the list with the expenses chart', (
      tester,
    ) async {
      setLandscape(tester);
      await startApp(tester);

      expect(find.byType(MainTopBar), findsNothing);
      expect(find.byType(MainBottomBar), findsNothing);

      expect(find.text('Total de despesas'), findsOneWidget);
      expect(find.text('R\$ 1000.00'), findsOneWidget);

      // Legend: localized category name, amount and percentage per slice.
      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('R\$ 500.00  (50%)'), findsOneWidget);
      expect(find.text('Transporte'), findsOneWidget);
      expect(find.text('R\$ 300.00  (30%)'), findsOneWidget);
      expect(find.text('Sem categoria'), findsOneWidget);
      expect(find.text('R\$ 200.00  (20%)'), findsOneWidget);
    });

    testWidgets('swipe changes the month while in landscape', (tester) async {
      setLandscape(tester);
      await startApp(tester);

      expect(find.text('R\$ 1000.00'), findsOneWidget);

      await tester.flingFrom(
        tester.getCenter(find.byType(app.RichLudoApp)),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Presente'), findsOneWidget);
      expect(find.text('R\$ 700.00'), findsOneWidget);
      expect(find.text('R\$ 1000.00'), findsNothing);
    });
  });
}
