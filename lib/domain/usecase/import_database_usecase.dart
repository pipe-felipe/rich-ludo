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
      debugPrint('[ImportDatabaseUseCase] Starting import...');

      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select backup file',
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('[ImportDatabaseUseCase] User cancelled');
        return Result.error(Exception('Import cancelled by user'));
      }

      final file = result.files.first;

      if (file.extension != 'ludo') {
        debugPrint('[ImportDatabaseUseCase] Invalid file: ${file.extension}');
        return Result.error(Exception('Invalid file. Select a .ludo file'));
      }

      Uint8List? bytes = file.bytes;

      if (bytes == null && file.path != null) {
        final backupFile = File(file.path!);
        if (await backupFile.exists()) {
          bytes = await backupFile.readAsBytes();
        }
      }

      if (bytes == null) {
        return Result.error(Exception('Could not read backup file'));
      }

      debugPrint(
        '[ImportDatabaseUseCase] Selected file: ${file.name}, ${bytes.length} bytes',
      );

      debugPrint('[ImportDatabaseUseCase] Closing current database...');
      await _exportService.closeDatabase();

      debugPrint('[ImportDatabaseUseCase] Importing backup...');
      final importResult = await _exportService.importDatabase(bytes);

      if (importResult.isError) {
        await _exportService.reopenDatabase();
        return importResult;
      }

      debugPrint('[ImportDatabaseUseCase] Reopening database...');
      await _exportService.reopenDatabase();

      debugPrint('[ImportDatabaseUseCase] Import completed successfully!');
      return Result.ok(null);
    } catch (e, stack) {
      debugPrint('[ImportDatabaseUseCase] ERROR: $e');
      debugPrint('[ImportDatabaseUseCase] Stack: $stack');

      try {
        await _exportService.reopenDatabase();
      } catch (_) {}

      return Result.error(
        e is Exception ? e : Exception('Error importing database: $e'),
      );
    }
  }
}
