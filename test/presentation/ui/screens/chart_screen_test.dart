import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/category_total.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/screens/chart_screen.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';

void main() {
  Future<void> pumpChartScreen(
    WidgetTester tester, {
    required List<CategoryTotal> categoryTotals,
    required int totalExpenseCents,
    required String totalExpenseText,
    required String currentMonthYear,
    List<CustomCategory> customCategories = const [],
    VoidCallback onPreviousMonth = _noop,
    VoidCallback onNextMonth = _noop,
    VoidCallback onCurrentMonthClick = _noop,
  }) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: ChartScreen(
            categoryTotals: categoryTotals,
            totalExpenseCents: totalExpenseCents,
            totalExpenseText: totalExpenseText,
            currentMonthYear: currentMonthYear,
            customCategories: customCategories,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onCurrentMonthClick: onCurrentMonthClick,
          ),
        ),
      ),
    );
  }

  group('ChartScreen', () {
    testWidgets('should show the month and the total expenses', (tester) async {
      await pumpChartScreen(
        tester,
        categoryTotals: const [
          CategoryTotal(category: 'food', amountCents: 10000),
        ],
        totalExpenseCents: 10000,
        totalExpenseText: 'R\$ 100.00',
        currentMonthYear: 'July 2026',
      );

      expect(find.text('July 2026'), findsOneWidget);
      expect(find.text('R\$ 100.00'), findsOneWidget);
      expect(find.text('Total de despesas'), findsOneWidget);
    });

    testWidgets('should show one legend entry per category', (tester) async {
      await pumpChartScreen(
        tester,
        categoryTotals: const [
          CategoryTotal(category: 'food', amountCents: 6000),
          CategoryTotal(category: 'transport', amountCents: 4000),
        ],
        totalExpenseCents: 10000,
        totalExpenseText: 'R\$ 100.00',
        currentMonthYear: 'July 2026',
      );

      expect(find.text('Comida'), findsOneWidget);
      expect(find.text('Transporte'), findsOneWidget);
    });

    testWidgets('should call onNextMonth when the right arrow is tapped', (
      tester,
    ) async {
      var nextMonthCalled = false;

      await pumpChartScreen(
        tester,
        categoryTotals: const [
          CategoryTotal(category: 'food', amountCents: 10000),
        ],
        totalExpenseCents: 10000,
        totalExpenseText: 'R\$ 100.00',
        currentMonthYear: 'July 2026',
        onNextMonth: () => nextMonthCalled = true,
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_right));
      await tester.pump();

      expect(nextMonthCalled, isTrue);
    });

    testWidgets('should call onPreviousMonth when the left arrow is tapped', (
      tester,
    ) async {
      var previousMonthCalled = false;

      await pumpChartScreen(
        tester,
        categoryTotals: const [
          CategoryTotal(category: 'food', amountCents: 10000),
        ],
        totalExpenseCents: 10000,
        totalExpenseText: 'R\$ 100.00',
        currentMonthYear: 'July 2026',
        onPreviousMonth: () => previousMonthCalled = true,
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_left));
      await tester.pump();

      expect(previousMonthCalled, isTrue);
    });
  });

  group('ChartScreen with user-created categories', () {
    testWidgets('should forward the list so the legend shows the stored name', (
      tester,
    ) async {
      await pumpChartScreen(
        tester,
        categoryTotals: const [
          CategoryTotal(category: 'custom_mercado', amountCents: 5000),
        ],
        totalExpenseCents: 5000,
        totalExpenseText: 'R\$ 50.00',
        currentMonthYear: 'Agosto 2026',
        customCategories: const [
          CustomCategory(
            id: 1,
            slug: 'custom_mercado',
            name: 'Mercado',
            type: TransactionType.expense,
            iconCodePoint: 0xe59c,
            colorValue: 0xFFC62828,
          ),
        ],
      );

      expect(find.text('Mercado'), findsOneWidget);
    });
  });
}

void _noop() {}
