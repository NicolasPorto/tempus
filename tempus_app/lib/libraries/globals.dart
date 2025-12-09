import 'package:flutter/foundation.dart';

class TempusGlobals extends ChangeNotifier {
  bool _onFocus = false;
  int _loadingCount = 0;

  bool get onFocus => _onFocus;
  bool get isLoading => _loadingCount > 0;

  set onFocus(bool newValue) {
    if (_onFocus != newValue) {
      _onFocus = newValue;
      notifyListeners();
    }
  }

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