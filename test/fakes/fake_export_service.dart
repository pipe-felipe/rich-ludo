import 'dart:typed_data';

import 'package:rich_ludo/data/services/export_service.dart';
import 'package:rich_ludo/utils/result.dart';

class FakeExportService implements ExportService {
  bool shouldReturnError = false;
  String fakeDatabasePath = '/fake/path/rich_ludo.db';
  String? lastExportDestination;
  Uint8List? lastImportedBytes;
  bool databaseClosed = false;

  @override
  Future<Result<String>> getDatabasePath() async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error when getting path'));
    }
    return Result.ok(fakeDatabasePath);
  }

  @override
  Future<Result<String>> exportDatabase(String destinationPath) async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error when exporting'));
    }
    lastExportDestination = destinationPath;
    return Result.ok(destinationPath);
  }

  @override
  Future<Result<void>> importDatabase(Uint8List backupBytes) async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error when importing'));
    }
    lastImportedBytes = backupBytes;
    return Result.ok(null);
  }

  @override
  Future<void> closeDatabase() async {
    databaseClosed = true;
  }

  @override
  Future<void> reopenDatabase() async {
    databaseClosed = false;
  }
}
