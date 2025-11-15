import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';

final screenDimmer = ScreenDimmer._internal();

class ScreenDimmer with ChangeNotifier {
  ScreenDimmer._internal();

  static const double _blackoutLevel = 1.0;

  double _blackoutOpacity = 0.0;
  bool _isActive = false;
  double _dragOffset = 0.0;
  double _minimumDragOffSet = -150.0;

  VoidCallback? onReveal;

  FlutterSoundRecorder? _recorder;
  StreamSubscription? _recorderSubscription;
  ValueNotifier<double> currentDecibels = ValueNotifier(0.0);

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

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _recorder = FlutterSoundRecorder();
      await _recorder!.openRecorder();

      _recorderSubscription = _recorder!.onProgress!.listen(
            (RecordingDisposition e) {
          if (e.decibels != null) {
            currentDecibels.value = e.decibels!;
          }
        },
        onError: (Object e) {
          print('Recorder Error: $e');
          _stopListening();
        },
      );

      await _recorder!.setSubscriptionDuration(const Duration(milliseconds: 100));

      await _recorder!.startRecorder(
        toFile: 'temp_audio.amr',
        codec: Codec.amrNB,
      );
    } else {
      print('Microphone permission denied.');
    }
  }

  Future<void> _stopListening() async {
    await _recorderSubscription?.cancel();
    _recorderSubscription = null;

    if (_recorder != null) {
      if (_recorder!.isRecording) {
        await _recorder!.stopRecorder();
      }
      await _recorder!.closeRecorder();
      _recorder = null;
    }
    currentDecibels.value = 0.0;
  }

  Future<void> startBlackout() async {
    if (_isActive) return;

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await _startListening();
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

  Future<void> stopBlackout() async {
    if (!_isActive) return;

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await _stopListening();
    _blackoutOpacity = 0.0;
    _isActive = false;
    resetDragOffset();
    notifyListeners();

    onReveal?.call();

    await WakelockPlus.disable();

    print('Escurecimento do App parado. Visualização restaurada.');
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}