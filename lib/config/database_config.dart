/// Configurações centralizadas do banco de dados SQLite
/// Evita duplicação de constantes em múltiplos serviços
class DatabaseConfig {
  DatabaseConfig._();

  static const String databaseName = 'rich_ludo.db';
  static const int databaseVersion = 1;
  static const String tableName = 'transactions';
}
