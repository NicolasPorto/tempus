import 'package:flutter/foundation.dart';

class TempusGlobals extends ChangeNotifier {
  bool _onFocus = false;
  int _loadingCount = 0;

  /// Pedido de troca de aba (ex.: "focar nesta tarefa" leva ao Timer).
  final ValueNotifier<int?> tabRequest = ValueNotifier(null);

  /// Incrementado quando sessões/tarefas mudam, para que as abas mantidas
  /// vivas (KeepAlive) recarreguem seus dados.
  final ValueNotifier<int> dataVersion = ValueNotifier(0);

  bool get onFocus => _onFocus;
  bool get isLoading => _loadingCount > 0;

  set onFocus(bool newValue) {
    if (_onFocus != newValue) {
      _onFocus = newValue;
      notifyListeners();
    }
  }

  void goToTab(int index) {
    tabRequest.value = null;
    tabRequest.value = index;
  }

  void markDataChanged() => dataVersion.value++;

  void startLoading() {
    _loadingCount++;
    if (_loadingCount == 1) {
      notifyListeners();
    }
  }

  void stopLoading() {
    if (_loadingCount > 0) {
      _loadingCount--;
      if (_loadingCount == 0) {
        notifyListeners();
      }
    }
  }
}

final tempusGlobals = TempusGlobals();
