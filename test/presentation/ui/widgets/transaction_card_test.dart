import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/l10n/app_localizations.dart';
import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
import 'package:rich_ludo/presentation/ui/widgets/transaction_card.dart';

void main() {
  Transaction cardTransaction({String? description, int amountCents = 5000}) {
    return Transaction(
      id: 1,
      amountCents: amountCents,
      type: TransactionType.expense,
      description: description,
      humanDate: '2026-08-04',
      targetMonth: 8,
      targetYear: 2026,
    );
  }

  Future<void> pumpCard(
    WidgetTester tester,
    Transaction item, {
    required void Function() onEdit,
    required void Function() onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: TransactionCard(item: item, onEdit: onEdit, onDelete: onDelete),
        ),
      ),
    );
  }

  group('TransactionCard', () {
    testWidgets('should show one edit button and one delete button', (
      tester,
    ) async {
      await pumpCard(tester, cardTransaction(), onEdit: () {}, onDelete: () {});

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should call onEdit when the pencil is tapped', (tester) async {
      var editCount = 0;
      var deleteCount = 0;
      await pumpCard(
        tester,
        cardTransaction(),
        onEdit: () => editCount++,
        onDelete: () => deleteCount++,
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(editCount, equals(1));
      expect(deleteCount, equals(0));
    });

    testWidgets('should call onDelete when the trash can is tapped', (
      tester,
    ) async {
      var editCount = 0;
      var deleteCount = 0;
      await pumpCard(
        tester,
        cardTransaction(),
        onEdit: () => editCount++,
        onDelete: () => deleteCount++,
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      expect(deleteCount, equals(1));
      expect(editCount, equals(0));
    });

    testWidgets('should lay the row out without overflowing a phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpCard(
        tester,
        cardTransaction(
          description: 'Uma descrição bem longa de transação',
          amountCents: 123456789,
        ),
        onEdit: () {},
        onDelete: () {},
      );

      expect(tester.takeException(), isNull);
    });
  });
}
