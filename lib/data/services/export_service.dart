import '../../utils/result.dart';

/// Interface abstrata para o serviço de exportação do banco de dados
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#services
abstract class ExportService {
  /// Retorna o caminho do arquivo do banco de dados atual
  Future<Result<String>> getDatabasePath();

  /// Exporta o banco de dados para o caminho especificado
  /// Retorna o caminho final do arquivo exportado
  Future<Result<String>> exportDatabase(String destinationPath);
}
