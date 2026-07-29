import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/theme/app_colors.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
import 'package:rich_ludo/presentation/ui/widgets/main_top_bar.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    required int incomeCents,
    required int expenseCents,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: MainTopBar(
            totalIncomeText: 'R\$ 0.00',
            totalExpenseText: 'R\$ 0.00',
            totalSavingText: 'R\$ 0.00',
            totalIncomeCents: incomeCents,
            totalExpenseCents: expenseCents,
            currentMonthYear: 'July/2026',
            onPreviousMonth: () {},
            onNextMonth: () {},
            onCurrentMonthClick: () {},
          ),
        ),
      ),
    );
  }

  Finder gaugeContainers() {
    final gauge = find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.height == 4,
    );
    return find.descendant(of: gauge, matching: find.byType(Container));
  }

  Color colorOf(WidgetTester tester, Finder finder) {
    return tester.widget<Container>(finder).color!;
  }

  group('MainTopBar income gauge', () {
    testWidgets('is empty when there is no income and no expense', (
      tester,
    ) async {
      await pumpBar(tester, incomeCents: 0, expenseCents: 0);

      expect(gaugeContainers(), findsNothing);
    });

    testWidgets('is fully the money color when nothing was spent', (
      tester,
    ) async {
      await pumpBar(tester, incomeCents: 10000, expenseCents: 0);

      final containers = gaugeContainers();
      expect(containers, findsOneWidget);
      expect(colorOf(tester, containers), LightPiColors.money);
    });

    testWidgets(
      'splits the gauge between spent and remaining income proportionally',
      (tester) async {
        await pumpBar(tester, incomeCents: 10000, expenseCents: 4000);

        final containers = gaugeContainers();
        expect(containers, findsNWidgets(2));

        final remaining = tester.widget<Flexible>(
          find.ancestor(of: containers.first, matching: find.byType(Flexible)),
        );
        final spent = tester.widget<Flexible>(
          find.ancestor(of: containers.last, matching: find.byType(Flexible)),
        );

        expect(colorOf(tester, containers.first), LightPiColors.money);
        expect(remaining.flex, equals(6000));
        expect(colorOf(tester, containers.last), isNot(LightPiColors.money));
        expect(spent.flex, equals(4000));
      },
    );

    testWidgets('is fully red when expenses equal the income', (tester) async {
      await pumpBar(tester, incomeCents: 5000, expenseCents: 5000);

      final containers = gaugeContainers();
      expect(containers, findsOneWidget);
      expect(colorOf(tester, containers), isNot(LightPiColors.money));
    });

    testWidgets('is fully red when expenses exceed the income', (tester) async {
      await pumpBar(tester, incomeCents: 5000, expenseCents: 8000);

      final containers = gaugeContainers();
      expect(containers, findsOneWidget);
      expect(colorOf(tester, containers), isNot(LightPiColors.money));
    });

    testWidgets('is fully red when there was spending but no income', (
      tester,
    ) async {
      await pumpBar(tester, incomeCents: 0, expenseCents: 3000);

      final containers = gaugeContainers();
      expect(containers, findsOneWidget);
      expect(colorOf(tester, containers), isNot(LightPiColors.money));
    });
  });
}
