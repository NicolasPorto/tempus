import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class TempusGlobals extends ChangeNotifier {
  bool _onFocus = false;

  bool get onFocus => _onFocus;

  set onFocus(bool newValue) {
    if (_onFocus != newValue) {
      _onFocus = newValue;
      notifyListeners();
    }
  }
}

final tempusGlobals = TempusGlobals();