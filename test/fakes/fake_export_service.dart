import 'package:rich_ludo/data/services/export_service.dart';
import 'package:rich_ludo/utils/result.dart';

/// Fake do ExportService para testes
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/testing
class FakeExportService implements ExportService {
  bool shouldReturnError = false;
  String fakeDatabasePath = '/fake/path/rich_ludo.db';
  String? lastExportDestination;

  @override
  Future<Result<String>> getDatabasePath() async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado ao obter caminho'));
    }
    return Result.ok(fakeDatabasePath);
  }

  @override
  Future<Result<String>> exportDatabase(String destinationPath) async {
    if (shouldReturnError) {
      return Result.error(Exception('Erro simulado ao exportar'));
    }
    lastExportDestination = destinationPath;
    return Result.ok(destinationPath);
  }
}
