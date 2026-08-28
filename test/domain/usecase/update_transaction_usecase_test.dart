import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/repository/transaction_repository.dart';
import 'package:rich_ludo/domain/usecase/update_transaction_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class FakeTransaction extends Fake implements Transaction {}

void main() {
  late MockTransactionRepository mockRepository;
  late UpdateTransactionUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTransaction());
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = UpdateTransactionUseCase(mockRepository);
  });

  group('UpdateTransactionUseCase', () {
    test('should return Result.ok with the updated row count', () async {
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Result.ok(1));

      final transaction = Transaction(
        id: 1,
        amountCents: 5000,
        type: TransactionType.expense,
      );

      final result = await useCase(transaction);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(1));
      verify(() => mockRepository.updateTransaction(any())).called(1);
    });

    test('should pass the transaction through unchanged', () async {
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Result.ok(1));

      final transaction = Transaction(
        id: 7,
        amountCents: 1234,
        type: TransactionType.income,
        category: 'salary',
        description: 'Bonus',
      );

      await useCase(transaction);

      final captured =
          verify(
                () => mockRepository.updateTransaction(captureAny()),
              ).captured.single
              as Transaction;
      expect(captured.id, equals(7));
      expect(captured.amountCents, equals(1234));
      expect(captured.type, equals(TransactionType.income));
      expect(captured.category, equals('salary'));
      expect(captured.description, equals('Bonus'));
    });

    test('should return Result.error when the repository fails', () async {
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Result.error(Exception('Database error')));

      final transaction = Transaction(
        id: 1,
        amountCents: 5000,
        type: TransactionType.expense,
      );

      final result = await useCase(transaction);

      expect(result.isError, isTrue);
    });
  });
}
