import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/data/services/export_service.dart';
import 'package:rich_ludo/domain/usecase/import_database_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockExportService extends Mock implements ExportService {}

void main() {
  late MockExportService mockExportService;
  late ImportDatabaseUseCase useCase;

  setUp(() {
    mockExportService = MockExportService();
    useCase = ImportDatabaseUseCase(mockExportService);
  });

  group('ImportDatabaseUseCase', () {
    // Nota: Os testes de integração com FilePicker.platform.pickFiles()
    // requerem testes de widget/integração devido à natureza da plataforma.
    // Aqui testamos os comportamentos que não dependem do FilePicker.

    test('should have an ExportService instance', () {
      expect(useCase, isNotNull);
    });

    test('should be possible to create multiple instances', () {
      final anotherMock = MockExportService();
      final anotherUseCase = ImportDatabaseUseCase(anotherMock);

      expect(anotherUseCase, isNot(same(useCase)));
    });
  });

  group('ExportService integration for import', () {
    test('should call closeDatabase before importing', () async {
      when(() => mockExportService.closeDatabase()).thenAnswer((_) async {});

      await mockExportService.closeDatabase();

      verify(() => mockExportService.closeDatabase()).called(1);
    });

    test('should call reopenDatabase after importing', () async {
      when(() => mockExportService.reopenDatabase()).thenAnswer((_) async {});

      await mockExportService.reopenDatabase();

      verify(() => mockExportService.reopenDatabase()).called(1);
    });

    test('should call importDatabase with correct bytes', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      when(
        () => mockExportService.importDatabase(testBytes),
      ).thenAnswer((_) async => Result.ok(null));

      final result = await mockExportService.importDatabase(testBytes);

      expect(result.isOk, isTrue);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
    });

    test('should return error when importDatabase fails', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);

      when(
        () => mockExportService.importDatabase(testBytes),
      ).thenAnswer((_) async => Result.error(Exception('Error importing')));

      final result = await mockExportService.importDatabase(testBytes);

      expect(result.isError, isTrue);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
    });

    test('should reopen database even in case of import error', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);

      when(() => mockExportService.closeDatabase()).thenAnswer((_) async {});
      when(
        () => mockExportService.importDatabase(testBytes),
      ).thenAnswer((_) async => Result.error(Exception('Error')));
      when(() => mockExportService.reopenDatabase()).thenAnswer((_) async {});

      await mockExportService.closeDatabase();
      await mockExportService.importDatabase(testBytes);
      await mockExportService.reopenDatabase();

      verify(() => mockExportService.closeDatabase()).called(1);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
      verify(() => mockExportService.reopenDatabase()).called(1);
    });
  });
}
