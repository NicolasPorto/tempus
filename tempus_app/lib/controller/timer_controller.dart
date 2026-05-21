import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibration/vibration.dart';
import 'package:tempus_app/libraries/screen_dimmer.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/services/supabase_service.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final ValueNotifier<bool> isFocusModeGlobalNotifier = ValueNotifier(false);

class TimerController extends ChangeNotifier {
  final SupabaseService supabaseService;
  InterstitialAd? _interstitialAd;
  final Random _random = Random();

  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  bool _isLoading = true;

  bool _isFocusMode = false;
  int _initialDuration = 25 * 60;
  int _currentDuration = 25 * 60;
  Timer? _timer;
  Timer? _autoDimmingTimer;
  bool _isRunning = false;
  String? _sessionUuid;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerReady = false;
  Uint8List? _beepSound;

  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;
  bool get isFocusMode => _isFocusMode;
  int get currentDuration => _currentDuration;
  int get initialDuration => _initialDuration;
  bool get isRunning => _isRunning;

  TimerController({required this.supabaseService}) {
    Future.microtask(() => _init());
    loadAd();
  }

  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-4001641241004927/2089137240',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showAdWithProbability() {
    if (_random.nextInt(3) == 0) {
      if (_interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAd = null;
        loadAd();
      } else {
        loadAd();
      }
    }
  }

  void setDuration(int minutes) {
    if (_isRunning) return;
    _initialDuration = minutes * 60;
    _currentDuration = _initialDuration;
    notifyListeners();
  }

  Future<void> _init() async {
    try {
      await _player.openPlayer();
      _isPlayerReady = true;
      await _loadBeepSound();
      screenDimmer.onReveal = _resetAutoDimmingTimer;
      await loadSubjects();
    } catch (e) {
      print('Erro na inicialização do TimerController: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoDimmingTimer?.cancel();
    screenDimmer.onReveal = null;
    _player.closePlayer();
    super.dispose();
  }

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await supabaseService.listCategories();
      _subjects = categories.map((e) => e.toSubject()).toList();

      if (_selectedSubject == null ||
          !_subjects.any((s) => s.id == _selectedSubject!.id)) {
        _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
      }
    } catch (e) {
      print('Erro ao carregar matérias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSubject(Subject? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void toggleTimer() {
    if (_selectedSubject == null) return;
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void resetTimer() {
    _stopTimer();
    _isFocusMode = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
  }

  void _startTimer() {
    if (_selectedSubject == null || _isRunning) return;

    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentDuration <= 0) {
          _stopTimer();
        } else {
          _currentDuration--;
          _checkAlerts();
          notifyListeners();
        }
      });
      _initiateFocusSession();
    } catch (e) {
      print('Error initiating focus session: $e');
    }

    _isRunning = true;
    _isFocusMode = true;
    isFocusModeGlobalNotifier.value = true;
    _resetAutoDimmingTimer();
    notifyListeners();
  }

  void _pauseTimer() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void _stopTimer() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _isRunning = false;
    _currentDuration = _initialDuration;

    if (_isFocusMode) {
      _isFocusMode = false;
      isFocusModeGlobalNotifier.value = false;
    }

    _stopFocusSession();
    _showAdWithProbability();
    notifyListeners();
  }

  Future<void> _initiateFocusSession() async {
    final int studyMinutes = _initialDuration ~/ 60;
    try {
      _sessionUuid = await supabaseService.startSession(
        studyMinutes,
        _selectedSubject!.id,
      );
    } catch (e) {
      print('Error initiating session: $e');
    }
  }

  Future<void> _stopFocusSession() async {
    if (_sessionUuid != null) {
      try {
        await supabaseService.stopSession(_sessionUuid!);
      } catch (e) {
        print('Error stopping focus: $e');
      } finally {
        _sessionUuid = null;
      }
    }
  }

  Future<void> _loadBeepSound() async {
    try {
      final data = await rootBundle.load('lib/assets/sounds/beep.mp3');
      _beepSound = data.buffer.asUint8List();
    } catch (e) {
      print('Error loading beep sound: $e');
    }
  }

  Future<void> _playBeep() async {
    if (!_isPlayerReady || _beepSound == null) return;
    try {
      await _player.startPlayer(fromDataBuffer: _beepSound);
    } catch (e) {
      print('Error playing beep: $e');
    }
  }

  void _checkAlerts() {
    final int elapsedSeconds = _initialDuration - _currentDuration;
    if (elapsedSeconds > 0) {
      if (elapsedSeconds % 60 == 0) {
        _triggerTenMinuteAlert();
      } else if (elapsedSeconds % 20 == 0) {
        _triggerFiveMinuteAlert();
      }
    }
  }

  Future<void> _triggerFiveMinuteAlert() async {
    _playBeep();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  Future<void> _triggerTenMinuteAlert() async {
    await _playBeep();
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    await _playBeep();
  }

  void _resetAutoDimmingTimer() {
    _autoDimmingTimer?.cancel();
    _autoDimmingTimer = Timer(const Duration(seconds: 5), () {
      if (_isRunning) {
        screenDimmer.startBlackout();
      }
    });
  }

  void handleUserInteraction() {
    if (_isRunning && screenDimmer.isActive) {
      screenDimmer.stopBlackout();
    }
  }
}
