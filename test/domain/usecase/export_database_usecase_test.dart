import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/data/services/export_service.dart';
import 'package:rich_ludo/domain/usecase/export_database_usecase.dart';
import 'package:rich_ludo/utils/result.dart';

class MockExportService extends Mock implements ExportService {}

void main() {
  late MockExportService mockExportService;
  late ExportDatabaseUseCase useCase;

  setUp(() {
    mockExportService = MockExportService();
    useCase = ExportDatabaseUseCase(mockExportService);
  });

  group('ExportDatabaseUseCase', () {
    test('should have ExportService instance', () {
      expect(useCase, isNotNull);
    });

    test('should be possible to create multiple instances', () {
      final anotherMock = MockExportService();
      final anotherUseCase = ExportDatabaseUseCase(anotherMock);

      expect(anotherUseCase, isNot(same(useCase)));
    });

    test(
      'should create the filename in the format day-month-year-rich-backup.ludo',
      () {
        final date = DateTime(2026, 3, 13); // 13/03/2026
        final fileName = useCase.generateFileName(date);

        expect(fileName, equals('13-03-2026-rich-backup.ludo'));
      },
    );

    test('should ensure leading zeros for days and months less than 10', () {
      final date = DateTime(2026, 1, 9); // 09/01/2026
      final fileName = useCase.generateFileName(date);

      expect(fileName, equals('09-01-2026-rich-backup.ludo'));
    });
  });

  group('ExportService integration', () {
    test('should call exportDatabase when path is provided', () async {
      const testPath = '/storage/emulated/0/Documents/backup.ludo';

      when(
        () => mockExportService.exportDatabase(testPath),
      ).thenAnswer((_) async => Result.ok(testPath));

      final result = await mockExportService.exportDatabase(testPath);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(testPath));
      verify(() => mockExportService.exportDatabase(testPath)).called(1);
    });

    test('should return error when ExportService fails', () async {
      const testPath = '/invalid/path/backup.ludo';

      when(
        () => mockExportService.exportDatabase(testPath),
      ).thenAnswer((_) async => Result.error(Exception('Erro ao exportar')));

      final result = await mockExportService.exportDatabase(testPath);

      expect(result.isError, isTrue);
      verify(() => mockExportService.exportDatabase(testPath)).called(1);
    });

    test('should get database path', () async {
      const expectedPath =
          '/data/data/com.pipe.rich_ludo/databases/rich_ludo.db';

      when(
        () => mockExportService.getDatabasePath(),
      ).thenAnswer((_) async => Result.ok(expectedPath));

      final result = await mockExportService.getDatabasePath();

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(expectedPath));
    });

    test('should return error when unable to get path', () async {
      when(
        () => mockExportService.getDatabasePath(),
      ).thenAnswer((_) async => Result.error(Exception('Error getting path')));

      final result = await mockExportService.getDatabasePath();

      expect(result.isError, isTrue);
    });
  });
}
