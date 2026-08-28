import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/recurring_scope.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
import 'package:rich_ludo/presentation/ui/widgets/recurring_scope_dialog.dart';

void main() {
  RecurringScope? returnedScope;

  Future<void> pumpDialog(
    WidgetTester tester, {
    required String title,
    Set<RecurringScope> disabledScopes = const {},
  }) async {
    returnedScope = null;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  returnedScope = await RecurringScopeDialog.show(
                    context,
                    title: title,
                    disabledScopes: disabledScopes,
                  );
                },
                child: const Text('abrir'),
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

  group('RecurringScopeDialog', () {
    testWidgets('should return the tapped scope when nothing is disabled', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        title: 'Editar recorrente',
        disabledScopes: const <RecurringScope>{},
      );

      await tester.tap(find.text('Apenas este mês'));
      await tester.pumpAndSettle();

      expect(returnedScope, equals(RecurringScope.thisMonth));
      expect(find.byType(RecurringScopeDialog), findsNothing);
    });

    testWidgets('should show the title it was given', (tester) async {
      await pumpDialog(tester, title: 'Editar recorrente');

      expect(find.text('Editar recorrente'), findsOneWidget);
    });

    testWidgets('should not return a disabled scope when it is tapped', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        title: 'Editar recorrente',
        disabledScopes: const {RecurringScope.thisAndPreviousMonths},
      );

      await tester.tap(find.text('Este mês e anteriores'));
      await tester.pumpAndSettle();

      expect(returnedScope, isNull);
      expect(find.byType(RecurringScopeDialog), findsOneWidget);
    });

    testWidgets('should keep the other scopes tappable while one is disabled', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        title: 'Editar recorrente',
        disabledScopes: const {RecurringScope.thisAndPreviousMonths},
      );

      await tester.tap(find.text('Todos os meses'));
      await tester.pumpAndSettle();

      expect(returnedScope, equals(RecurringScope.allMonths));
    });
  });
}
