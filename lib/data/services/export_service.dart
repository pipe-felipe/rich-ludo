import 'dart:typed_data';

import '../../utils/result.dart';

/// Abstract interface for the database export/import service
/// Following: https://docs.flutter.dev/app-architecture/guide#services
abstract class ExportService {
  /// Returns the path of the current database file
  Future<Result<String>> getDatabasePath();

  /// Exports the database to the specified path
  /// Returns the final exported file path
  Future<Result<String>> exportDatabase(String destinationPath);

  /// Imports the database from the backup file bytes
  /// Replaces the current database with the backup
  Future<Result<void>> importDatabase(Uint8List backupBytes);

  /// Closes the current database connection
  /// Required before replacing the file
  Future<void> closeDatabase();

  /// Reopens the database connection after an import
  Future<void> reopenDatabase();
}
