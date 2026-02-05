import 'dart:typed_data';

import '../../utils/result.dart';

/// Interface abstrata para o serviço de exportação/importação do banco de dados
/// Seguindo: https://docs.flutter.dev/app-architecture/guide#services
abstract class ExportService {
  /// Retorna o caminho do arquivo do banco de dados atual
  Future<Result<String>> getDatabasePath();

  /// Exporta o banco de dados para o caminho especificado
  /// Retorna o caminho final do arquivo exportado
  Future<Result<String>> exportDatabase(String destinationPath);

  /// Importa o banco de dados a partir dos bytes do arquivo de backup
  /// Substitui o banco atual pelo backup
  Future<Result<void>> importDatabase(Uint8List backupBytes);

  /// Fecha a conexão atual com o banco de dados
  /// Necessário antes de substituir o arquivo
  Future<void> closeDatabase();

  /// Reabre a conexão com o banco de dados após importação
  Future<void> reopenDatabase();
}
