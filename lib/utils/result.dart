sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;

  const factory Result.error(Exception error) = Error<T>;

  bool get isOk => this is Ok<T>;

  bool get isError => this is Error<T>;

  Ok<T> get asOk => this as Ok<T>;

  Error<T> get asError => this as Error<T>;
}

final class Ok<T> extends Result<T> {
  final T value;

  const Ok(this.value);

  @override
  String toString() => 'Ok($value)';
}

final class Error<T> extends Result<T> {
  final Exception error;

  const Error(this.error);

  @override
  String toString() => 'Error($error)';
}

extension ResultExtension<T> on Result<T> {
  R fold<R>({
    required R Function(T value) onOk,
    required R Function(Exception error) onError,
  }) {
    return switch (this) {
      Ok<T>(:final value) => onOk(value),
      Error<T>(:final error) => onError(error),
    };
  }

  T? get valueOrNull => switch (this) {
    Ok<T>(:final value) => value,
    Error<T>() => null,
  };

  Exception? get errorOrNull => switch (this) {
    Ok<T>() => null,
    Error<T>(:final error) => error,
  };
}
