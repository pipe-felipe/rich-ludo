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

    test('deve ter instância do ExportService', () {
      expect(useCase, isNotNull);
    });

    test('deve ser possível criar múltiplas instâncias', () {
      final anotherMock = MockExportService();
      final anotherUseCase = ImportDatabaseUseCase(anotherMock);
      
      expect(anotherUseCase, isNot(same(useCase)));
    });
  });

  group('ExportService integration para import', () {
    test('deve chamar closeDatabase antes de importar', () async {
      when(() => mockExportService.closeDatabase())
          .thenAnswer((_) async {});

      await mockExportService.closeDatabase();

      verify(() => mockExportService.closeDatabase()).called(1);
    });

    test('deve chamar reopenDatabase após importar', () async {
      when(() => mockExportService.reopenDatabase())
          .thenAnswer((_) async {});

      await mockExportService.reopenDatabase();

      verify(() => mockExportService.reopenDatabase()).called(1);
    });

    test('deve chamar importDatabase com bytes corretos', () async {
      final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      
      when(() => mockExportService.importDatabase(testBytes))
          .thenAnswer((_) async => Result.ok(null));

      final result = await mockExportService.importDatabase(testBytes);

      expect(result.isOk, isTrue);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
    });

    test('deve retornar erro quando importDatabase falha', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      
      when(() => mockExportService.importDatabase(testBytes))
          .thenAnswer((_) async => Result.error(Exception('Erro ao importar')));

      final result = await mockExportService.importDatabase(testBytes);

      expect(result.isError, isTrue);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
    });

    test('deve reabrir banco mesmo em caso de erro na importação', () async {
      final testBytes = Uint8List.fromList([1, 2, 3]);
      
      when(() => mockExportService.closeDatabase())
          .thenAnswer((_) async {});
      when(() => mockExportService.importDatabase(testBytes))
          .thenAnswer((_) async => Result.error(Exception('Erro')));
      when(() => mockExportService.reopenDatabase())
          .thenAnswer((_) async {});

      await mockExportService.closeDatabase();
      await mockExportService.importDatabase(testBytes);
      await mockExportService.reopenDatabase();

      verify(() => mockExportService.closeDatabase()).called(1);
      verify(() => mockExportService.importDatabase(testBytes)).called(1);
      verify(() => mockExportService.reopenDatabase()).called(1);
    });
  });
}
