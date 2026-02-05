import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../data/services/export_service.dart';
import '../../utils/result.dart';

/// Caso de uso para exportar o banco de dados para um arquivo .ludo
/// Seguindo: https://docs.flutter.dev/app-architecture/case-study/business-logic#use-cases
class ExportDatabaseUseCase {
  final ExportService _exportService;

  ExportDatabaseUseCase(this._exportService);

  /// Executa a exportação do banco de dados
  /// Abre um seletor de pasta para o usuário escolher onde salvar
  Future<Result<String>> call() async {
    try {
      debugPrint('[ExportDatabaseUseCase] Iniciando exportação...');

      // Obter caminho do banco de dados original
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

      // Ler bytes do banco de dados
      final bytes = await sourceFile.readAsBytes();

      // Gerar nome do arquivo com timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = 'rich_ludo_backup_$timestamp.ludo';

      // Abrir diálogo para escolher onde salvar
      // No Android/iOS, saveFile precisa receber bytes diretamente
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
