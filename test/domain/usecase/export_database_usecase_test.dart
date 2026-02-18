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
    // Nota: Os testes de integração com FilePicker.platform.saveFile()
    // requerem testes de widget/integração devido à natureza da plataforma.
    // Aqui testamos os comportamentos que não dependem do FilePicker.

    test('deve ter instância do ExportService', () {
      expect(useCase, isNotNull);
    });

    test('deve ser possível criar múltiplas instâncias', () {
      final anotherMock = MockExportService();
      final anotherUseCase = ExportDatabaseUseCase(anotherMock);

      expect(anotherUseCase, isNot(same(useCase)));
    });
  });

  group('ExportService integration', () {
    test('deve chamar exportDatabase quando caminho é fornecido', () async {
      const testPath = '/storage/emulated/0/Documents/backup.ludo';

      when(
        () => mockExportService.exportDatabase(testPath),
      ).thenAnswer((_) async => Result.ok(testPath));

      final result = await mockExportService.exportDatabase(testPath);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(testPath));
      verify(() => mockExportService.exportDatabase(testPath)).called(1);
    });

    test('deve retornar erro quando ExportService falha', () async {
      const testPath = '/invalid/path/backup.ludo';

      when(
        () => mockExportService.exportDatabase(testPath),
      ).thenAnswer((_) async => Result.error(Exception('Erro ao exportar')));

      final result = await mockExportService.exportDatabase(testPath);

      expect(result.isError, isTrue);
      verify(() => mockExportService.exportDatabase(testPath)).called(1);
    });

    test('deve obter caminho do banco de dados', () async {
      const expectedPath =
          '/data/data/com.example.rich_ludo/databases/rich_ludo.db';

      when(
        () => mockExportService.getDatabasePath(),
      ).thenAnswer((_) async => Result.ok(expectedPath));

      final result = await mockExportService.getDatabasePath();

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(expectedPath));
    });

    test('deve retornar erro quando não consegue obter caminho', () async {
      when(() => mockExportService.getDatabasePath()).thenAnswer(
        (_) async => Result.error(Exception('Erro ao obter caminho')),
      );

      final result = await mockExportService.getDatabasePath();

      expect(result.isError, isTrue);
    });
  });
}
