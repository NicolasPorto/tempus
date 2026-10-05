import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus_app/libraries/globals.dart';
import 'package:tempus_app/libraries/screen_dimmer.dart';
import 'package:tempus_app/models/subject.dart';
import 'package:tempus_app/models/task.dart';
import 'package:tempus_app/services/supabase_service.dart';
import 'dart:math';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tempus_app/services/notification_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tempus_app/core/demo.dart';

final ValueNotifier<bool> isFocusModeGlobalNotifier = ValueNotifier(false);

enum PomodoroPhase { work, shortBreak, longBreak }

/// Estado do timer. Fica acima das abas (provido em [NavigationContainer])
/// para que Perfil, Tarefas e Stats compartilhem a mesma instância.
class TimerController extends ChangeNotifier with WidgetsBindingObserver {
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

  /// Instante em que a contagem atual chega a zero. O tempo restante é
  /// derivado do relógio real a cada tick, então o timer não "atrasa" nem
  /// congela quando o app vai para segundo plano.
  DateTime? _endTime;

  int _sessionElapsedSeconds = 0;
  Timer? _autoDimmingTimer;
  bool _isRunning = false;
  String? _sessionUuid;

  // Daily tracking
  int _dailyMinutes = 0;
  int _dailyGoalMinutes = 0;
  int _streak = 0;

  // Session summary
  bool _showingSessionSummary = false;
  Subject? _summarySubject;
  int _summaryMinutes = 0;
  TaskItem? _summaryTask;

  // Tarefa em foco (opcional)
  TaskItem? _focusTask;

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
  static const String goalPrefKey = 'daily_goal_minutes';
  static const String _soundStylePrefKey = 'timer_sound_style';
  static const String _intervalAlertsPrefKey = 'interval_alerts_enabled';

  String _soundStyle = 'triple';
  bool _intervalAlerts = true;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerReady = false;
  Uint8List? _beepSound;

  List<Subject> get subjects => _subjects;
  Subject? get selectedSubject => _selectedSubject;
  bool get isLoading => _isLoading;
  String get soundStyle => _soundStyle;
  bool get intervalAlerts => _intervalAlerts;
  bool get isFocusMode => _isFocusMode;
  int get currentDuration => _currentDuration;
  int get initialDuration => _initialDuration;
  bool get isRunning => _isRunning;
  bool get isPaused => !_isRunning && _currentDuration < _initialDuration;
  bool get isPomodoroMode => _isPomodoroMode;
  PomodoroPhase get pomodoroPhase => _pomodoroPhase;
  int get pomodoroRound => _pomodoroRound;
  int get dailyMinutes => _dailyMinutes;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  int get streak => _streak;
  bool get showingSessionSummary => _showingSessionSummary;
  Subject? get summarySubject => _summarySubject;
  int get summaryMinutes => _summaryMinutes;
  TaskItem? get summaryTask => _summaryTask;
  TaskItem? get focusTask => _focusTask;
  String get focusQuote => _focusQuote;

  /// Horário previsto de término (considera o tempo restante a partir de agora).
  DateTime get projectedEnd =>
      _endTime ?? DateTime.now().add(Duration(seconds: _currentDuration));

  TimerController({required this.supabaseService}) {
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => _init());
    if (!kDemoMode) loadAd();
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
    if (kDemoMode) return;
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
    if (_isRunning || minutes <= 0) return;
    _initialDuration = minutes * 60;
    _currentDuration = _initialDuration;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setInt(_durationPrefKey, minutes));
    notifyListeners();
  }

  Future<void> setDailyGoal(int minutes) async {
    _dailyGoalMinutes = minutes;
    notifyListeners();
    _updateHomeWidget();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalPrefKey, minutes);
  }

  void _updateHomeWidget() {
    if (kDemoMode) return;
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
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_soundStylePrefKey, style);
  }

  Future<void> setIntervalAlerts(bool enabled) async {
    _intervalAlerts = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_intervalAlertsPrefKey, enabled);
  }

  void setPomodoroMode(bool enabled) {
    if (_isPomodoroMode != enabled) togglePomodoroMode();
  }

  void togglePomodoroMode() {
    if (_isRunning || isPaused) return;
    HapticFeedback.selectionClick();
    _pomodoroTransitionToken++;
    _isPomodoroMode = !_isPomodoroMode;
    if (_isPomodoroMode) {
      _pomodoroPhase = PomodoroPhase.work;
      _pomodoroRound = 0;
      _initialDuration = _pomodoroWorkMinutes * 60;
      _currentDuration = _initialDuration;
    } else {
      _restoreSavedDuration();
    }
    notifyListeners();
  }

  Future<void> _restoreSavedDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_durationPrefKey) ?? 25;
    if (_isRunning || _isPomodoroMode) return;
    _initialDuration = saved * 60;
    _currentDuration = _initialDuration;
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
      if (savedMinutes != null && !_isRunning) {
        _initialDuration = savedMinutes * 60;
        _currentDuration = _initialDuration;
      }
      _dailyGoalMinutes = prefs.getInt(goalPrefKey) ?? 0;
      _soundStyle = prefs.getString(_soundStylePrefKey) ?? 'triple';
      _intervalAlerts = prefs.getBool(_intervalAlertsPrefKey) ?? true;
    } catch (e) {
      debugPrint('Error loading prefs: $e');
    }

    screenDimmer.onReveal = _resetAutoDimmingTimer;
    await Future.wait([loadSubjects(), refreshDailyStats()]);
  }

  /// Recarrega minutos de hoje e sequência atual.
  Future<void> refreshDailyStats() async {
    try {
      final results = await Future.wait([
        supabaseService.getDailyMinutes(),
        supabaseService.getStreak(),
      ]);
      _dailyMinutes = results[0];
      _streak = results[1];
      _updateHomeWidget();
      if (!_disposed) notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily stats: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ao voltar para o app, sincroniza imediatamente com o relógio real.
    if (state == AppLifecycleState.resumed && _isRunning) _tick();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
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
      if (!_disposed) notifyListeners();
    }
  }

  void selectSubject(Subject? subject) {
    HapticFeedback.selectionClick();
    _selectedSubject = subject;
    if (_focusTask != null && _focusTask!.subjectId != subject?.id) {
      _focusTask = null;
    }
    notifyListeners();
  }

  /// Prepara o timer para trabalhar em uma tarefa específica: seleciona a
  /// matéria dela e usa a meta de minutos da tarefa como duração.
  bool focusOnTask(TaskItem task) {
    if (_isRunning || isPaused) return false;
    final subject = _subjects.where((s) => s.id == task.subjectId);
    if (subject.isEmpty) return false;
    _pomodoroTransitionToken++;
    _isPomodoroMode = false;
    _selectedSubject = subject.first;
    _focusTask = task;
    _initialDuration = task.minutesMeta * 60;
    _currentDuration = _initialDuration;
    notifyListeners();
    return true;
  }

  void clearFocusTask() {
    _focusTask = null;
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

  /// Adiciona minutos à sessão atual (rodando ou pausada).
  void extendSession(int minutes) {
    final extra = minutes * 60;
    _initialDuration += extra;
    _currentDuration += extra;
    if (_endTime != null) {
      _endTime = _endTime!.add(Duration(seconds: extra));
      _scheduleEndNotification();
    }
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void resetTimer() {
    _pomodoroTransitionToken++;
    _timer?.cancel();
    _endTime = null;
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    NotificationService().cancelSessionEnd();
    _isRunning = false;
    _stopFocusSession().then((minutes) {
      if (minutes > 0) {
        _dailyMinutes += minutes;
        _updateHomeWidget();
        tempusGlobals.markDataChanged();
        if (!_disposed) notifyListeners();
      }
    });

    if (_isPomodoroMode) {
      _pomodoroPhase = PomodoroPhase.work;
      _pomodoroRound = 0;
      _initialDuration = _pomodoroWorkMinutes * 60;
      _currentDuration = _initialDuration;
    } else {
      // Volta para a duração escolhida (descarta extensões "+5 min").
      _currentDuration = _initialDuration;
      _restoreDurationAfterSession();
    }
    _isFocusMode = false;
    _showingSessionSummary = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
  }

  void _restoreDurationAfterSession() {
    if (_focusTask != null) {
      _initialDuration = _focusTask!.minutesMeta * 60;
      _currentDuration = _initialDuration;
    } else {
      _restoreSavedDuration();
    }
  }

  void dismissSessionSummary() {
    _closeSummary();
    // Defer ad to after widget tree has settled to avoid rebuild crash
    Future.delayed(const Duration(milliseconds: 400), _showAdWithProbability);
  }

  void continueAfterSummary() => _closeSummary();

  void _closeSummary() {
    _showingSessionSummary = false;
    _summarySubject = null;
    _summaryTask = null;
    _isFocusMode = false;
    isFocusModeGlobalNotifier.value = false;
    notifyListeners();
  }

  /// Conclui a tarefa trabalhada na sessão que acabou de terminar.
  Future<void> completeSummaryTask() async {
    final task = _summaryTask;
    if (task == null) return;
    HapticFeedback.mediumImpact();
    task.done = true;
    if (_focusTask?.id == task.id) _focusTask = null;
    _summaryTask = null;
    notifyListeners();
    await supabaseService.toggleTask(task.id, true);
    tempusGlobals.markDataChanged();
  }

  void _startTimer() {
    if (_selectedSubject == null || _isRunning) return;

    // Nova frase só quando a sessão começa do zero (não ao retomar).
    if (!isPaused || _focusQuote.isEmpty) {
      _focusQuote = _quotes[_random.nextInt(_quotes.length)];
    }

    final isWork = !_isPomodoroMode || _pomodoroPhase == PomodoroPhase.work;
    if (isWork && _sessionUuid == null) {
      _initiateFocusSession();
    }

    _endTime = DateTime.now().add(Duration(seconds: _currentDuration));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());

    _isRunning = true;
    _isFocusMode = true;
    isFocusModeGlobalNotifier.value = true;
    _scheduleEndNotification();
    _resetAutoDimmingTimer();
    notifyListeners();
  }

  void _tick() {
    final end = _endTime;
    if (end == null || !_isRunning) return;
    final remaining =
        (end.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    final next = max(0, remaining);
    if (next == _currentDuration) return;

    final delta = _currentDuration - next;
    final before = _sessionElapsedSeconds;
    _currentDuration = next;
    _sessionElapsedSeconds += delta;
    _checkAlerts(before, _sessionElapsedSeconds);

    if (_currentDuration <= 0) {
      _onTimerNaturalEnd();
    } else {
      notifyListeners();
    }
  }

  void _scheduleEndNotification() {
    final end = _endTime;
    if (end == null) return;
    final subject = _selectedSubject?.name ?? 'Estudo';
    final body = _isPomodoroMode && _pomodoroPhase != PomodoroPhase.work
        ? 'Pausa encerrada — hora de voltar ao foco.'
        : '$subject · bom trabalho! Abra o Tempus para registrar.';
    NotificationService().scheduleSessionEnd(end, body: body);
  }

  void _pauseTimer() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _tick();
    _endTime = null;
    NotificationService().cancelSessionEnd();
    _isRunning = false;
    notifyListeners();
  }

  int _elapsedMinutes() => _sessionElapsedSeconds >= 60
      ? _sessionElapsedSeconds ~/ 60
      : (_sessionElapsedSeconds > 0 ? 1 : 0);

  void _onTimerNaturalEnd() {
    _autoDimmingTimer?.cancel();
    screenDimmer.stopBlackout();
    _timer?.cancel();
    _endTime = null;
    _isRunning = false;

    // O app está em primeiro plano: o alerta sonoro substitui a notificação.
    NotificationService().cancelSessionEnd();

    final isWork = !_isPomodoroMode || _pomodoroPhase == PomodoroPhase.work;
    // Calcula antes de _stopFocusSession zerar o contador.
    final int minutesStudied = isWork ? _elapsedMinutes() : 0;

    if (isWork) {
      _stopFocusSession();
      _addDailyMinutes(minutesStudied);
    }

    _playCompletionAlert();

    if (_isPomodoroMode) {
      _handlePomodoroTransition();
    } else {
      _summarySubject = _selectedSubject;
      _summaryMinutes = minutesStudied;
      _summaryTask = _focusTask;
      _showingSessionSummary = true;
      _restoreDurationAfterSession();
      _currentDuration = _initialDuration;
      HapticFeedback.heavyImpact();
      notifyListeners();
    }
  }

  void _addDailyMinutes(int minutes) {
    if (minutes <= 0) return;
    final bool goalJustReached = _dailyGoalMinutes > 0 &&
        _dailyMinutes < _dailyGoalMinutes &&
        (_dailyMinutes + minutes) >= _dailyGoalMinutes;
    final bool firstToday = _dailyMinutes == 0;
    _dailyMinutes += minutes;
    if (firstToday) {
      // Primeira sessão do dia mantém/estende a sequência.
      supabaseService.getStreak().then((s) {
        _streak = s;
        if (!_disposed) notifyListeners();
      });
    }
    _updateHomeWidget();
    tempusGlobals.markDataChanged();
    if (goalJustReached) {
      NotificationService().showGoalReachedNotification();
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
    final int studyMinutes = max(1, _initialDuration ~/ 60);
    try {
      _sessionUuid = await supabaseService.startSession(
        studyMinutes,
        _selectedSubject!.id,
      );
    } catch (e) {
      debugPrint('Error initiating session: $e');
    }
  }

  /// Encerra a sessão no backend e retorna os minutos reais registrados.
  Future<int> _stopFocusSession() async {
    final realMinutes = _elapsedMinutes();
    final id = _sessionUuid;
    _sessionUuid = null;
    _sessionElapsedSeconds = 0;
    if (id == null) return 0;
    try {
      await supabaseService.stopSession(id, realMinutes: realMinutes);
    } catch (e) {
      debugPrint('Error stopping focus: $e');
    }
    return realMinutes;
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

  /// Alertas de intervalo durante o foco: toque curto a cada 5 min e duplo
  /// a cada 10 min. (Antes disparavam a cada 20s/60s — valores de debug.)
  void _checkAlerts(int beforeSeconds, int afterSeconds) {
    if (!_intervalAlerts || _currentDuration <= 0) return;
    if (afterSeconds ~/ 600 > beforeSeconds ~/ 600) {
      _triggerTenMinuteAlert();
    } else if (afterSeconds ~/ 300 > beforeSeconds ~/ 300) {
      _triggerFiveMinuteAlert();
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
    } else if (_isRunning) {
      _resetAutoDimmingTimer();
    }
  }
}
