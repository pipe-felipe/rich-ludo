import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/export_service.dart';
import '../../utils/result.dart';

/// Caso de uso para importar/restaurar o banco de dados a partir de um arquivo .ludo
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/business-logic#use-cases
class ImportDatabaseUseCase {
  final ExportService _exportService;

  ImportDatabaseUseCase(this._exportService);

  /// Executa a importação do banco de dados
  /// Abre um seletor de arquivo para o usuário escolher o backup .ludo
  Future<Result<void>> call() async {
    try {
      debugPrint('[ImportDatabaseUseCase] Iniciando importação...');

      // Abrir diálogo para escolher arquivo de backup
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
      
      // Verificar se é um arquivo .ludo
      if (file.extension != 'ludo') {
        debugPrint('[ImportDatabaseUseCase] Arquivo inválido: ${file.extension}');
        return Result.error(Exception('Arquivo inválido. Selecione um arquivo .ludo'));
      }

      // Obter bytes do arquivo
      Uint8List? bytes = file.bytes;
      
      // Se bytes não veio pelo picker (pode acontecer em algumas plataformas)
      // tentar ler do path
      if (bytes == null && file.path != null) {
        final backupFile = File(file.path!);
        if (await backupFile.exists()) {
          bytes = await backupFile.readAsBytes();
        }
      }

      if (bytes == null) {
        return Result.error(Exception('Não foi possível ler o arquivo de backup'));
      }

      debugPrint('[ImportDatabaseUseCase] Arquivo selecionado: ${file.name}, ${bytes.length} bytes');

      // Fechar conexão atual com o banco
      debugPrint('[ImportDatabaseUseCase] Fechando banco atual...');
      await _exportService.closeDatabase();

      // Importar o backup
      debugPrint('[ImportDatabaseUseCase] Importando backup...');
      final importResult = await _exportService.importDatabase(bytes);

      if (importResult.isError) {
        // Tentar reabrir o banco mesmo em caso de erro
        await _exportService.reopenDatabase();
        return importResult;
      }

      // Reabrir conexão com o banco restaurado
      debugPrint('[ImportDatabaseUseCase] Reabrindo banco...');
      await _exportService.reopenDatabase();

      debugPrint('[ImportDatabaseUseCase] Importação concluída com sucesso!');
      return Result.ok(null);
    } catch (e, stack) {
      debugPrint('[ImportDatabaseUseCase] ERRO: $e');
      debugPrint('[ImportDatabaseUseCase] Stack: $stack');
      
      // Tentar reabrir o banco em caso de exceção
      try {
        await _exportService.reopenDatabase();
      } catch (_) {}
      
      return Result.error(
        e is Exception ? e : Exception('Erro ao importar banco de dados: $e'),
      );
    }
  }
}
