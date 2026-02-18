import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/export_service.dart';
import '../../utils/result.dart';

class ImportDatabaseUseCase {
  final ExportService _exportService;

  ImportDatabaseUseCase(this._exportService);

  Future<Result<void>> call() async {
    try {
      debugPrint('[ImportDatabaseUseCase] Iniciando importação...');

      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecione o arquivo de backup',
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('[ImportDatabaseUseCase] Usuário cancelou');
        return Result.error(Exception('Importação cancelada pelo usuário'));
      }

      final file = result.files.first;

      if (file.extension != 'ludo') {
        debugPrint(
          '[ImportDatabaseUseCase] Arquivo inválido: ${file.extension}',
        );
        return Result.error(
          Exception('Arquivo inválido. Selecione um arquivo .ludo'),
        );
      }

      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null) {
        final backupFile = File(file.path!);
        if (await backupFile.exists()) {
          bytes = await backupFile.readAsBytes();
        }
      }

      if (bytes == null) {
        return Result.error(
          Exception('Não foi possível ler o arquivo de backup'),
        );
      }

      debugPrint(
        '[ImportDatabaseUseCase] Arquivo selecionado: ${file.name}, ${bytes.length} bytes',
      );

      debugPrint('[ImportDatabaseUseCase] Fechando banco atual...');
      await _exportService.closeDatabase();

      debugPrint('[ImportDatabaseUseCase] Importando backup...');
      final importResult = await _exportService.importDatabase(bytes);

      if (importResult.isError) {
        await _exportService.reopenDatabase();
        return importResult;
      }

      debugPrint('[ImportDatabaseUseCase] Reabrindo banco...');
      await _exportService.reopenDatabase();

      debugPrint('[ImportDatabaseUseCase] Importação concluída com sucesso!');
      return Result.ok(null);
    } catch (e, stack) {
      debugPrint('[ImportDatabaseUseCase] ERRO: $e');
      debugPrint('[ImportDatabaseUseCase] Stack: $stack');

      try {
        await _exportService.reopenDatabase();
      } catch (_) {}

      return Result.error(
        e is Exception ? e : Exception('Erro ao importar banco de dados: $e'),
      );
    }
  }
}
