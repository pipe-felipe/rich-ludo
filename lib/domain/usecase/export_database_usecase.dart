import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/export_service.dart';
import '../../utils/result.dart';

class ExportDatabaseUseCase {
  final ExportService _exportService;

  ExportDatabaseUseCase(this._exportService);

  Future<Result<String>> call() async {
    try {
      debugPrint('[ExportDatabaseUseCase] Iniciando exportação...');

      final dbPathResult = await _exportService.getDatabasePath();
      if (dbPathResult.isError) {
        return Result.error(dbPathResult.asError.error);
      }

      final sourcePath = dbPathResult.asOk.value;
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        debugPrint('[ExportDatabaseUseCase] Banco não existe em: $sourcePath');
        return Result.error(Exception('Banco de dados não encontrado'));
      }

      final bytes = await sourceFile.readAsBytes();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'rich_ludo_backup_$timestamp.ludo';

      debugPrint('[ExportDatabaseUseCase] Abrindo seletor de pasta...');

      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Escolha onde salvar o backup',
        fileName: backupFileName,
        type: FileType.any,
        bytes: bytes,
      );

      if (selectedPath == null) {
        debugPrint('[ExportDatabaseUseCase] Usuário cancelou');
        return Result.error(Exception('Exportação cancelada pelo usuário'));
      }

      debugPrint('[ExportDatabaseUseCase] Salvo em: $selectedPath');

      return Result.ok(selectedPath);
    } catch (e, stack) {
      debugPrint('[ExportDatabaseUseCase] ERRO: $e');
      debugPrint('[ExportDatabaseUseCase] Stack: $stack');
      return Result.error(
        e is Exception ? e : Exception('Erro ao exportar banco de dados: $e'),
      );
    }
  }
}
