import 'package:flutter/foundation.dart';
import 'result.dart';

abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  bool get running => _running;

  bool get error => _result is Error;

  bool get completed => _result is Ok;

  Result<T>? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

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

class Command0<T> extends Command<T> {
  final Future<Result<T>> Function() _action;

  Command0(this._action);

  factory Command0.executing(Future<Result<T>> Function() action) {
    final command = Command0(action);
    command.execute();
    return command;
  }

  Future<void> execute() => executeAction(_action);
}

class Command1<T, A> extends Command<T> {
  final Future<Result<T>> Function(A) _action;

  Command1(this._action);

  Future<void> execute(A arg) => executeAction(() => _action(arg));
}

class Command2<T, A, B> extends Command<T> {
  final Future<Result<T>> Function(A, B) _action;

  Command2(this._action);

  Future<void> execute(A arg1, B arg2) => executeAction(() => _action(arg1, arg2));
}
