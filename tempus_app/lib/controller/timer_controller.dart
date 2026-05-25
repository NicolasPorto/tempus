import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus_app/libraries/screen_dimmer.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/services/supabase_service.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tempus_app/services/notification_service.dart';
import 'package:home_widget/home_widget.dart';

final ValueNotifier<bool> isFocusModeGlobalNotifier = ValueNotifier(false);

enum PomodoroPhase { work, shortBreak, longBreak }

class TimerController extends ChangeNotifier {
  final SupabaseService supabaseService;
  InterstitialAd? _interstitialAd;
  final Random _random = Random();

  List<Subject> _subjects = [];
  Subject? _selectedSubject;
  bool _isLoading = true;
  bool _disposed = false;

  bool _isFocusMode = false;
  int _initialDuration = 25 * 60;
  int _currentDuration = 25 * 60;
  Timer? _timer;

  int _sessionElapsedSeconds = 0;
  Timer? _autoDimmingTimer;
  bool _isRunning = false;
  String? _sessionUuid;

  // Daily tracking
  int _dailyMinutes = 0;
  int _dailyGoalMinutes = 0;

  // Session summary
  bool _showingSessionSummary = false;
  Subject? _summarySubject;
  int _summaryMinutes = 0;

  // Focus mode quote (picked once per session start)
  String _focusQuote = '';

  // Pomodoro
  bool _isPomodoroMode = false;
  PomodoroPhase _pomodoroPhase = PomodoroPhase.work;
  int _pomodoroRound = 0;
  int _pomodoroTransitionToken = 0;
  static const int _pomodoroWorkMinutes = 25;
  static const int _pomodoroShortBreakMinutes = 5;
  static const int _pomodoroLongBreakMinutes = 15;

  static const _quotes = [
    'Deep work gera resultados reais.',
    'Cada minuto de foco conta.',
    'Consistência supera talento.',
    'Você está mais perto do que imagina.',
    'O esforço de hoje é o sucesso de amanhã.',
    'Um passo de cada vez.',
    'Foco total. Sem distrações.',
    'Estudar é investir em você mesmo.',
    'A mente forte faz o que precisa ser feito.',
    'Pequenos progressos todos os dias.',
  ];

  static const String _durationPrefKey = 'last_timer_duration_minutes';
  static const String _goalPrefKey = 'daily_goal_minutes';
  static const String _soundStylePrefKey = 'timer_sound_style';

  String _soundStyle = 'triple';

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerReady = false;
  Uint8List? _beepSound;

  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;
  String get soundStyle => _soundStyle;
  bool get isFocusMode => _isFocusMode;
  int get currentDuration => _currentDuration;
  int get initialDuration => _initialDuration;
  bool get isRunning => _isRunning;
  bool get isPomodoroMode => _isPomodoroMode;
  PomodoroPhase get pomodoroPhase => _pomodoroPhase;
  int get pomodoroRound => _pomodoroRound;
  int get dailyMinutes => _dailyMinutes;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  bool get showingSessionSummary => _showingSessionSummary;
  Subject? get summarySubject => _summarySubject;
  int get summaryMinutes => _summaryMinutes;
  String get focusQuote => _focusQuote;

  TimerController({required this.supabaseService}) {
    Future.microtask(() => _init());
    loadAd();
  }

  void loadAd() {
    MobileAds.instance.initialize().then((_) {
      if (_disposed) return;
      try {
        InterstitialAd.load(
          adUnitId: 'ca-app-pub-4001641241004927/2089137240',
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              if (!_disposed) {
                _interstitialAd = ad;
              } else {
                ad.dispose();
              }
            },
            onAdFailedToLoad: (error) {
              _interstitialAd = null;
            },
          ),
        );
      } catch (e) {
        debugPrint('Error loading ad: $e');
      }
    }).catchError((e) {
      debugPrint('Error initializing MobileAds: $e');
    });
  }

  void _showAdWithProbability() {
    if (_interstitialAd == null) {
      loadAd();
      return;
    }
    if (_random.nextInt(3) == 0) {
      try {
        _interstitialAd!.show();
        _interstitialAd = null;
        loadAd();
      } catch (e) {
        debugPrint('Error showing ad: $e');
        _interstitialAd = null;
      }
    }
  }

  void setDuration(int minutes) {
    if (_isRunning) return;
    _initialDuration = minutes * 60;
    _currentDuration = _initialDuration;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(_durationPrefKey, minutes));
    notifyListeners();
  }

  Future<void> setDailyGoal(int minutes) async {
    _dailyGoalMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalPrefKey, minutes);
    notifyListeners();
  }

  void _updateHomeWidget() {
    try {
      HomeWidget.saveWidgetData<int>('daily_minutes', _dailyMinutes);
      HomeWidget.saveWidgetData<int>('goal_minutes', _dailyGoalMinutes);
      HomeWidget.updateWidget(
        androidName: 'TempusWidget',
        qualifiedAndroidName: 'com.dev.tempusapp.TempusWidget',
      );
    } catch (e) {
      debugPrint('HomeWidget update error: $e');
    }
  }

  Future<void> setSoundStyle(String style) async {
    _soundStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundStylePrefKey, style);
    notifyListeners();
  }

  void togglePomodoroMode() {
    if (_isRunning) return;
    _pomodoroTransitionToken++;
    _isPomodoroMode = !_isPomodoroMode;
    if (_isPomodoroMode) {
      _pomodoroPhase = PomodoroPhase.work;
      _pomodoroRound = 0;
      _initialDuration = _pomodoroWorkMinutes * 60;
      _currentDuration = _initialDuration;
    }
    notifyListeners();
  }

  Future<void> _init() async {
    try {
      await _player.openPlayer();
      _isPlayerReady = true;
      await _loadBeepSound();
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }

    // Load persisted settings
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMinutes = prefs.getInt(_durationPrefKey);
      if (savedMinutes != null) {
        _initialDuration = savedMinutes * 60;
        _currentDuration = _initialDuration;
      }
      _dailyGoalMinutes = prefs.getInt(_goalPrefKey) ?? 0;
      _soundStyle = prefs.getString(_soundStylePrefKey) ?? 'triple';
    } catch (e) {
      debugPrint('Error loading prefs: $e');
    }

    // Load today's study minutes
    try {
      _dailyMinutes = await supabaseService.getDailyMinutes();
      _updateHomeWidget();
    } catch (e) {
      debugPrint('Error loading daily minutes: $e');
    }

    screenDimmer.onReveal = _resetAutoDimmingTimer;
    await loadSubjects();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _autoDimmingTimer?.cancel();
    screenDimmer.onReveal = null;
    isFocusModeGlobalNotifier.value = false;
    _interstitialAd?.dispose();
    if (_isPlayerReady) {
      _player
          .closePlayer()
          .catchError((e) => debugPrint('Error closing player: $e'));
    }
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
      } else {
        _selectedSubject =
            _subjects.firstWhere((s) => s.id == _selectedSubject!.id);
      }
    } catch (e) {
      debugPrint('Erro ao carregar matérias: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectSubject(Subject? subject) {
    HapticFeedback.selectionClick();
    _selectedSubject = subject;
    notifyListeners();
  }

  void toggleTimer() {
    if (_selectedSubject == null) return;
    if (_isRunning) {
      HapticFeedback.mediumImpact();
      _pauseTimer();
    } else {
      HapticFeedback.heavyImpact();
      _startTimer();
    }
  }

  void resetTimer() {
    _pomodoroTransitionToken++;
    _timer?.cancel();
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _isRunning = false;
    _stopFocusSession();

    if (_isPomodoroMode) {
      _pomodoroPhase = PomodoroPhase.work;
      _pomodoroRound = 0;
      _initialDuration = _pomodoroWorkMinutes * 60;
    }
    _currentDuration = _initialDuration;
    _isFocusMode = false;
    _showingSessionSummary = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
  }

  void dismissSessionSummary() {
    _showingSessionSummary = false;
    _summarySubject = null;
    _isFocusMode = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
    // Defer ad to after widget tree has settled to avoid rebuild crash
    Future.delayed(const Duration(milliseconds: 400), _showAdWithProbability);
  }

  void continueAfterSummary() {
    _showingSessionSummary = false;
    _summarySubject = null;
    _isFocusMode = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
  }

  void _startTimer() {
    if (_selectedSubject == null || _isRunning) return;

    // Pick a motivational quote for this session
    _focusQuote = _quotes[_random.nextInt(_quotes.length)];

    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_currentDuration <= 0) {
          _onTimerNaturalEnd();
        } else {
          _currentDuration--;
          _sessionElapsedSeconds++;
          _checkAlerts();
          notifyListeners();
        }
      });

      if (!_isPomodoroMode || _pomodoroPhase == PomodoroPhase.work) {
        _initiateFocusSession();
      }

      _isRunning = true;
      _isFocusMode = true;
      isFocusModeGlobalNotifier.value = true;
      _resetAutoDimmingTimer();
    } catch (e) {
      debugPrint('Error starting timer: $e');
      _timer?.cancel();
      _timer = null;
    }
    notifyListeners();
  }

  void _pauseTimer() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void _onTimerNaturalEnd() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _isRunning = false;

    // Compute elapsed BEFORE _stopFocusSession zeros the counter
    final int minutesStudied = _sessionElapsedSeconds >= 60
        ? _sessionElapsedSeconds ~/ 60
        : (_sessionElapsedSeconds > 0 ? 1 : 0);

    if (!_isPomodoroMode || _pomodoroPhase == PomodoroPhase.work) {
      _stopFocusSession();
    }

    _playCompletionAlert();

    if (_isPomodoroMode) {
      _handlePomodoroTransition();
    } else {
      final bool goalJustReached = _dailyGoalMinutes > 0 &&
          _dailyMinutes < _dailyGoalMinutes &&
          (_dailyMinutes + minutesStudied) >= _dailyGoalMinutes;
      _dailyMinutes += minutesStudied;
      _updateHomeWidget();
      if (goalJustReached) {
        NotificationService().showGoalReachedNotification();
      }
      _currentDuration = _initialDuration;
      // Show session summary instead of immediately exiting focus mode
      _summarySubject = _selectedSubject;
      _summaryMinutes = minutesStudied;
      _showingSessionSummary = true;
      HapticFeedback.heavyImpact();
      notifyListeners();
    }
  }

  void _handlePomodoroTransition() {
    if (_pomodoroPhase == PomodoroPhase.work) {
      _pomodoroRound++;
      if (_pomodoroRound % 4 == 0) {
        _pomodoroPhase = PomodoroPhase.longBreak;
        _initialDuration = _pomodoroLongBreakMinutes * 60;
      } else {
        _pomodoroPhase = PomodoroPhase.shortBreak;
        _initialDuration = _pomodoroShortBreakMinutes * 60;
      }
    } else {
      _pomodoroPhase = PomodoroPhase.work;
      _initialDuration = _pomodoroWorkMinutes * 60;
    }
    _currentDuration = _initialDuration;
    final int token = ++_pomodoroTransitionToken;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (!_disposed &&
          token == _pomodoroTransitionToken &&
          _isPomodoroMode &&
          !_isRunning &&
          _selectedSubject != null) {
        _startTimer();
      }
    });
  }

  Future<void> _initiateFocusSession() async {
    _sessionElapsedSeconds = 0;
    final int studyMinutes = _initialDuration ~/ 60;
    try {
      _sessionUuid = await supabaseService.startSession(
        studyMinutes,
        _selectedSubject!.id,
      );
    } catch (e) {
      debugPrint('Error initiating session: $e');
    }
  }

  Future<void> _stopFocusSession() async {
    if (_sessionUuid != null) {
      final int realMinutes = _sessionElapsedSeconds >= 60
          ? _sessionElapsedSeconds ~/ 60
          : (_sessionElapsedSeconds > 0 ? 1 : 0);
      try {
        await supabaseService.stopSession(_sessionUuid!, realMinutes: realMinutes);
      } catch (e) {
        debugPrint('Error stopping focus: $e');
      } finally {
        _sessionUuid = null;
        _sessionElapsedSeconds = 0;
      }
    }
  }

  Future<void> _loadBeepSound() async {
    try {
      final data = await rootBundle.load('lib/assets/sounds/beep.mp3');
      _beepSound = data.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error loading beep sound: $e');
    }
  }

  Future<void> _playBeep() async {
    if (!_isPlayerReady || _beepSound == null) return;
    try {
      await _player.startPlayer(fromDataBuffer: _beepSound);
    } catch (e) {
      debugPrint('Error playing beep: $e');
    }
  }

  Future<void> _playCompletionAlert() async {
    switch (_soundStyle) {
      case 'single':
        await _playBeep();
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 300);
        }
      case 'vibration_only':
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [0, 400, 200, 400, 200, 400]);
        }
      default: // 'triple'
        await _playBeep();
        await Future.delayed(const Duration(milliseconds: 400));
        await _playBeep();
        await Future.delayed(const Duration(milliseconds: 400));
        await _playBeep();
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
        }
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
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 100);
    }
  }

  Future<void> _triggerTenMinuteAlert() async {
    await _playBeep();
    if (await Vibration.hasVibrator()) {
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
