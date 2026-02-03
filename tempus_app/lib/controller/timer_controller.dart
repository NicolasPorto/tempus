import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibration/vibration.dart';
import 'package:tempus_app/libraries/screen_dimmer.dart';
import 'package:tempus_app/models/session.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/services/api_service.dart';
import 'package:tempus_app/services/storage_service.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final ValueNotifier<bool> isFocusModeGlobalNotifier = ValueNotifier(false);

class TimerController extends ChangeNotifier {
  final ApiService apiService;
  InterstitialAd? _interstitialAd;
  final Random _random = Random();

  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  bool _isLoading = true;

  // --- Estados do Timer ---
  bool _isFocusMode = false;
  static const int _initialDuration = 25 * 60;
  int _currentDuration = _initialDuration;
  Timer? _timer;
  Timer? _autoDimmingTimer;
  bool _isRunning = false;
  String? _sessionUuid;

  // --- Áudio ---
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerReady = false;
  Uint8List? _beepSound;

  // --- Getters ---
  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;
  bool get isFocusMode => _isFocusMode;
  int get currentDuration => _currentDuration;
  int get initialDuration => _initialDuration;
  bool get isRunning => _isRunning;

  TimerController({required this.apiService}) {
    Future.microtask(() => _init());
    loadAd();
  }

  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // ID de Teste Intersticial
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print("Anúncio carregado com sucesso!"); // Adicione este log
        },
        onAdFailedToLoad: (error) {
          print("Falha ao carregar: $error");
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

  Future<void> _init() async {
    try {
      await _player.openPlayer();
      _isPlayerReady = true;
      await _loadBeepSound();
      
      screenDimmer.onReveal = _resetAutoDimmingTimer;
      
      await loadSubjects();
    } catch (e) {
      print("Erro na inicialização do TimerController: $e");
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

  // --- Gerenciamento de Matérias ---
  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      var categories = await apiService.listAllCategories();
      final subjectsList = categories.map((e) => e.toSubject()).toList();

      _subjects = subjectsList;
      
      if (_selectedSubject == null || !_subjects.contains(_selectedSubject)) {
        _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
      }
    } catch (e) {
      print("Erro ao carregar matérias: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSubject(Subject? subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  // --- Lógica do Timer ---
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

    if (_selectedSubject != null) {
      final session = SessionLog(
        subjectId: _selectedSubject!.id,
        durationMinutes: (_initialDuration - _currentDuration) ~/ 60,
      );
      StorageService.instance.addSessionLog(session);
    }

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

  // --- API Helpers ---
  Future<void> _initiateFocusSession() async {
    final int studyMinutes = _initialDuration ~/ 60;
    try {
      final result = await Future.wait([
        apiService.initiateFocus(DateTime.now(), studyMinutes, _selectedSubject!.id)
      ]);
      _sessionUuid = result[0];
    } catch (e) {
      print('Error initiating session API: $e');
    }
  }

  Future<void> _stopFocusSession() async {
    if (_sessionUuid != null) {
      try {
        await apiService.stopFocus(_sessionUuid!);
      } catch (e) {
        print('Error stopping focus: $e');
      } finally {
        _sessionUuid = null;
      }
    }
  }

  // --- Áudio e Alertas ---
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

  // --- Dimmer Logic ---
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