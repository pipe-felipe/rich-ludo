import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/category_total.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
import 'package:rich_ludo/presentation/ui/widgets/chart/pie_chart.dart';

void main() {
  Future<void> pumpChartWidget(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(body: child),
      ),
    );
  }

  group('categoryPercentage', () {
    test('should return the rounded share of the total', () {
      expect(categoryPercentage(2500, 10000), equals(25));
    });

    test('should return zero when the total is zero', () {
      expect(categoryPercentage(500, 0), equals(0));
    });
  });

  group('CategoryLegend', () {
    final categoryTotals = const [
      CategoryTotal(category: 'food', amountCents: 5000),
      CategoryTotal(category: 'transport', amountCents: 3000),
      CategoryTotal(category: null, amountCents: 2000),
    ];

    testWidgets('should render one row per category', (tester) async {
      await pumpChartWidget(
        tester,
        CategoryLegend(
          categoryTotals: categoryTotals,
          totalExpenseCents: 10000,
        ),
      );

      expect(find.byType(Row), findsAtLeastNWidgets(3));
      expect(find.textContaining('%'), findsNWidgets(3));
    });

    testWidgets('should show the localized label, amount and percentage', (
      tester,
    ) async {
      await pumpChartWidget(
        tester,
        CategoryLegend(
          categoryTotals: categoryTotals,
          totalExpenseCents: 10000,
        ),
      );

      expect(find.text('R\$ 50.00  (50%)'), findsOneWidget);
      expect(find.text('Comida'), findsOneWidget);
    });

    testWidgets('should render nothing when there are no categories', (
      tester,
    ) async {
      await pumpChartWidget(
        tester,
        const CategoryLegend(categoryTotals: [], totalExpenseCents: 0),
      );

      expect(find.textContaining('%'), findsNothing);
    });
  });

  group('PieChart', () {
    testWidgets('should build one section per category', (tester) async {
      await pumpChartWidget(
        tester,
        const PieChart(
          categoryTotals: [
            CategoryTotal(category: 'food', amountCents: 5000),
            CategoryTotal(category: 'transport', amountCents: 3000),
            CategoryTotal(category: null, amountCents: 2000),
          ],
          totalExpenseCents: 10000,
        ),
      );

      final widget = tester.widget<fl.PieChart>(find.byType(fl.PieChart));
      expect(widget.data.sections.length, equals(3));
    });
  });

  group('CategoryLegend with user-created categories', () {
    const custom = CustomCategory(
      id: 1,
      slug: 'custom_mercado',
      name: 'Mercado',
      type: TransactionType.expense,
      iconCodePoint: 0xe59c,
      colorValue: 0xFFC62828,
    );

    testWidgets('should show the stored name of a user-created slug', (
      tester,
    ) async {
      await pumpChartWidget(
        tester,
        const CategoryLegend(
          categoryTotals: [
            CategoryTotal(category: 'custom_mercado', amountCents: 5000),
          ],
          totalExpenseCents: 5000,
          customCategories: [custom],
        ),
      );

      expect(find.text('Mercado'), findsOneWidget);
    });

    testWidgets('should show the uncategorized label without the list', (
      tester,
    ) async {
      await pumpChartWidget(
        tester,
        const CategoryLegend(
          categoryTotals: [
            CategoryTotal(category: 'custom_mercado', amountCents: 5000),
          ],
          totalExpenseCents: 5000,
        ),
      );

      expect(find.text('Sem categoria'), findsOneWidget);
    });
  });
}
