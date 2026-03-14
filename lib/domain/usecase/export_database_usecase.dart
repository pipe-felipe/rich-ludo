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
      debugPrint('[ExportDatabaseUseCase] Starting export...');

      final dbPathResult = await _exportService.getDatabasePath();
      if (dbPathResult.isError) {
        return Result.error(dbPathResult.asError.error);
      }

      final sourcePath = dbPathResult.asOk.value;
      final sourceFile = File(sourcePath);

      if (!await sourceFile.exists()) {
        debugPrint(
          '[ExportDatabaseUseCase] Database not found at: $sourcePath',
        );
        return Result.error(Exception('Database not found'));
      }

      final bytes = await sourceFile.readAsBytes();

      final backupFileName = generateFileName(DateTime.now());

      debugPrint('[ExportDatabaseUseCase] Opening folder picker...');

      final selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select where to save backup',
        fileName: backupFileName,
        type: FileType.any,
        bytes: bytes,
      );

      if (selectedPath == null) {
        debugPrint('[ExportDatabaseUseCase] User cancelled');
        return Result.error(Exception('Export cancelled by user'));
      }

      debugPrint('[ExportDatabaseUseCase] Saved to: $selectedPath');

      return Result.ok(selectedPath);
    } catch (e, stack) {
      debugPrint('[ExportDatabaseUseCase] ERROR: $e');
      debugPrint('[ExportDatabaseUseCase] Stack: $stack');
      return Result.error(
        e is Exception ? e : Exception('Error exporting database: $e'),
      );
    }
  }

  @visibleForTesting
  String generateFileName(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day-$month-$year-rich-backup.ludo';
  }
}
