class DatabaseConfig {
  DatabaseConfig._();

  static const String databaseName = 'rich_ludo.db';
  static const int databaseVersion = 2;
  static const String tableName = 'transactions';
  static const String exclusionsTableName = 'recurring_exclusions';
}
