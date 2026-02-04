import 'package:flutter/foundation.dart';
import 'result.dart';

/// Padrão Command para gerenciar estados assíncronos em ViewModels
/// Baseado na arquitetura recomendada pelo Flutter: https://docs.flutter.dev/app-architecture/case-study/ui-layer#command-objects
/// 
/// Commands encapsulam operações assíncronas e expõem estados de loading, sucesso e erro
/// para que a UI possa reagir de forma padronizada.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  /// true se a ação está em execução
  bool get running => _running;

  /// true se a ação completou com erro
  bool get error => _result is Error;

  /// true se a ação completou com sucesso
  bool get completed => _result is Ok;

  /// Resultado da última execução
  Result<T>? get result => _result;

  /// Limpa o resultado e volta ao estado inicial
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  /// Executa a ação interna
  @protected
  Future<void> executeAction(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } catch (e) {
      _result = Result.error(e is Exception ? e : Exception(e.toString()));
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// Command sem parâmetros
class Command0<T> extends Command<T> {
  final Future<Result<T>> Function() _action;

  Command0(this._action);

  /// Cria e já executa o command
  factory Command0.executing(Future<Result<T>> Function() action) {
    final command = Command0(action);
    command.execute();
    return command;
  }

  /// Executa a ação
  Future<void> execute() => executeAction(_action);
}

/// Command com 1 parâmetro
class Command1<T, A> extends Command<T> {
  final Future<Result<T>> Function(A) _action;

  Command1(this._action);

  /// Executa a ação com o argumento fornecido
  Future<void> execute(A arg) => executeAction(() => _action(arg));
}

/// Command com 2 parâmetros
class Command2<T, A, B> extends Command<T> {
  final Future<Result<T>> Function(A, B) _action;

  Command2(this._action);

  /// Executa a ação com os argumentos fornecidos
  Future<void> execute(A arg1, B arg2) => executeAction(() => _action(arg1, arg2));
}
