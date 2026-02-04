/// Tipo Result para tratamento robusto de erros
/// Baseado na arquitetura recomendada pelo Flutter: https://docs.flutter.dev/app-architecture/design-patterns/result
sealed class Result<T> {
  const Result();

  /// Cria um Result de sucesso com o valor fornecido
  const factory Result.ok(T value) = Ok<T>;

  /// Cria um Result de erro com a exceção fornecida
  const factory Result.error(Exception error) = Error<T>;

  /// Retorna true se o resultado é de sucesso
  bool get isOk => this is Ok<T>;

  /// Retorna true se o resultado é de erro
  bool get isError => this is Error<T>;

  /// Retorna o resultado como Ok, lança se for Error
  Ok<T> get asOk => this as Ok<T>;

  /// Retorna o resultado como Error, lança se for Ok
  Error<T> get asError => this as Error<T>;
}

/// Representa um resultado de sucesso
final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);

  @override
  String toString() => 'Ok($value)';
}

/// Representa um resultado de erro
final class Error<T> extends Result<T> {
  final Exception error;

  const Error(this.error);

  @override
  String toString() => 'Error($error)';
}

/// Extensão para facilitar o uso do Result
extension ResultExtension<T> on Result<T> {
  /// Executa [onOk] se for sucesso ou [onError] se for erro
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Exception error) onError,
  }) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Error<T>(:final error) => onError(error),
    };
  }

  /// Retorna o valor ou null se for erro
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Error<T>() => null,
      };

  /// Retorna o erro ou null se for sucesso
  Exception? get errorOrNull => switch (this) {
        Ok<T>() => null,
        Error<T>(:final error) => error,
      };
}
