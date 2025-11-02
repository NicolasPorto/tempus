import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final screenDimmer = ScreenDimmer._internal();

class ScreenDimmer with ChangeNotifier {
  ScreenDimmer._internal();

  static const double _blackoutLevel = 0.99;
  static const Duration _restoreDuration = Duration(seconds: 5);
  
  double _blackoutOpacity = 0.9;
  Timer? _reBlackoutTimer;
  bool _isActive = false;
  double _dragOffset = 0.0; 
  double _minimumDragOffSet = -150.0;

  double get blackoutOpacity => _blackoutOpacity;
  bool get isActive => _isActive; 
  double get dragOffset => _dragOffset;
  double get minimumDragOffSet => _minimumDragOffSet;

  void updateDragOffset(double delta) {
    _dragOffset = (_dragOffset + delta).clamp(-300.0, 0.0);
    notifyListeners();
  }

  void resetDragOffset() {
    _dragOffset = 0.0;
    notifyListeners();
  }

  Future<void> startBlackout() async {
    if (_isActive) return;

    try {
      _blackoutOpacity = _blackoutLevel;
      _isActive = true;
      notifyListeners();
      
      await WakelockPlus.enable();
      
      print('Escurecimento do App ativo.'); 
    } catch (e) {
      print('Erro ao iniciar escurecimento: $e'); 
      _isActive = false;
    }
  }

  void restoreTemporary() {
    if (!_isActive) return;
    
    _reBlackoutTimer?.cancel();
    _blackoutOpacity = 0.0;
    notifyListeners(); 

    _reBlackoutTimer = Timer(_restoreDuration, () {
      if (_isActive) { 
        _blackoutOpacity = _blackoutLevel;
        notifyListeners();
        print('Escurecimento do App restaurado após inatividade.');
        resetDragOffset();
      }
    });
  }

  Future<void> stopBlackout() async {
    if (!_isActive) return;

    _reBlackoutTimer?.cancel();
    
    _blackoutOpacity = 0.0;
    _isActive = false;
    resetDragOffset(); 
    notifyListeners();

    await WakelockPlus.disable();
    
    print('Escurecimento do App parado. Visualização restaurada.'); 
  }

  @override
  void dispose() {
    _reBlackoutTimer?.cancel();
    super.dispose();
  }
}