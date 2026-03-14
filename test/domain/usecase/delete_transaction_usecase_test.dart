import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/repository/transaction_repository.dart';
import 'package:rich_ludo/domain/usecase/delete_transaction_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late MockTransactionRepository mockRepository;
  late DeleteTransactionUseCase useCase;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransactionUseCase(mockRepository);
  });

  group('DeleteTransactionUseCase', () {
    test(
      'should delete transaction and return Result.ok with affected rows',
      () async {
        const transactionId = 42;

        when(
          () => mockRepository.deleteTransaction(transactionId),
        ).thenAnswer((_) async => const Result.ok(1));

        final result = await useCase(transactionId);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1));
        verify(() => mockRepository.deleteTransaction(transactionId)).called(1);
      },
    );

    test(
      'should return Result.ok with 0 when transaction does not exist',
      () async {
        const transactionId = 999;

        when(
          () => mockRepository.deleteTransaction(transactionId),
        ).thenAnswer((_) async => const Result.ok(0));

        final result = await useCase(transactionId);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(0));
        verify(() => mockRepository.deleteTransaction(transactionId)).called(1);
      },
    );

    test('should return Result.error when repository fails', () async {
      const transactionId = 42;

      when(
        () => mockRepository.deleteTransaction(transactionId),
      ).thenAnswer((_) async => Result.error(Exception('Database error')));

      final result = await useCase(transactionId);

      expect(result.isError, isTrue);
      verify(() => mockRepository.deleteTransaction(transactionId)).called(1);
    });
  });
}
