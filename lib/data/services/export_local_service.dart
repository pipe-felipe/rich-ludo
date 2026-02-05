import 'dart:io';
import 'dart:typed_data';

import '../../utils/result.dart';
import '../local/database/database_helper.dart';
import 'export_service.dart';

class ExportLocalService implements ExportService {
  final DatabaseHelper _databaseHelper;

  ExportLocalService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<Result<String>> getDatabasePath() async {
    try {
      final fullPath = await _databaseHelper.getDatabasePath();
      return Result.ok(fullPath);
    } catch (e) {
      return Result.error(
        e is Exception ? e : Exception('Erro ao obter caminho do banco: $e'),
      );
    }
  }

  @override
  Future<Result<String>> exportDatabase(String destinationPath) async {
    try {
      final sourcePathResult = await getDatabasePath();

      if (sourcePathResult.isError) {
        return Result.error(sourcePathResult.asError.error);
      }

      final sourcePath = sourcePathResult.asOk.value;
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        return Result.error(
          Exception('Arquivo de banco de dados não encontrado'),
        );
      }

      // Copia o arquivo para o destino
      await sourceFile.copy(destinationPath);

      return Result.ok(destinationPath);
    } catch (e) {
      return Result.error(
        e is Exception ? e : Exception('Erro ao exportar banco de dados: $e'),
      );
    }
  }

  @override
  Future<Result<void>> importDatabase(Uint8List backupBytes) async {
    try {
      final dbPathResult = await getDatabasePath();
      if (dbPathResult.isError) {
        return Result.error(dbPathResult.asError.error);
      }

      final dbPath = dbPathResult.asOk.value;
      final dbFile = File(dbPath);

      // Escrever os bytes do backup no arquivo do banco
      await dbFile.writeAsBytes(backupBytes, flush: true);

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        e is Exception ? e : Exception('Erro ao importar banco de dados: $e'),
      );
    }
  }

  @override
  Future<void> closeDatabase() async {
    await _databaseHelper.close();
  }

  @override
  Future<void> reopenDatabase() async {
    await _databaseHelper.database;
  }
}
