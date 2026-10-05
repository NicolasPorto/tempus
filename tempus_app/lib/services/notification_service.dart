import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _kReminderEnabled = 'notif_reminder_enabled';
const _kReminderHour = 'notif_reminder_hour';
const _kReminderMinute = 'notif_reminder_minute';

const _idReminder = 1;
const _idGoalReached = 2;
const _idSessionEnd = 3;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;

    // Re-schedule saved reminder after init
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kReminderEnabled) ?? false;
    if (enabled) {
      final hour = prefs.getInt(_kReminderHour) ?? 20;
      final minute = prefs.getInt(_kReminderMinute) ?? 0;
      await scheduleDailyReminder(hour: hour, minute: minute);
    }
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> scheduleDailyReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    if (!_initialized) await init();
    await _plugin.cancel(_idReminder);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, true);
    await prefs.setInt(_kReminderHour, hour);
    await prefs.setInt(_kReminderMinute, minute);

    // tz.local nunca é configurado (fica em UTC), então montamos o horário
    // no fuso do aparelho e convertemos para um instante absoluto em UTC.
    final now = DateTime.now();
    var local = DateTime(now.year, now.month, now.day, hour, minute);
    if (local.isBefore(now)) {
      local = local.add(const Duration(days: 1));
    }
    final scheduled = tz.TZDateTime.from(local, tz.UTC);

    try {
      await _plugin.zonedSchedule(
        _idReminder,
        '⏱ Hora de estudar!',
        'Você ainda não estudou hoje. Abra o Tempus e mantenha sua sequência.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tempus_reminder',
            'Lembrete diário',
            channelDescription: 'Lembrete para estudar todos os dias',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Reminder scheduled at $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  Future<void> cancelDailyReminder() async {
    await _plugin.cancel(_idReminder);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, false);
  }

  Future<void> showGoalReachedNotification() async {
    if (!_initialized) await init();
    try {
      await _plugin.show(
        _idGoalReached,
        '🎉 Meta do dia atingida!',
        'Incrível! Você completou sua meta de estudos de hoje. Continue assim!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tempus_achievement',
            'Conquistas',
            channelDescription: 'Notificações de metas e conquistas',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing goal notification: $e');
    }
  }

  /// Agenda o aviso de fim de sessão — garante o alerta mesmo se o sistema
  /// suspender o app em segundo plano.
  Future<void> scheduleSessionEnd(DateTime at, {required String body}) async {
    if (!_initialized) await init();
    try {
      await _plugin.cancel(_idSessionEnd);
      await _plugin.zonedSchedule(
        _idSessionEnd,
        '✅ Sessão concluída!',
        body,
        tz.TZDateTime.from(at, tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tempus_session',
            'Fim de sessão',
            channelDescription: 'Aviso quando uma sessão de foco termina',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Error scheduling session end: $e');
    }
  }

  Future<void> cancelSessionEnd() async {
    try {
      await _plugin.cancel(_idSessionEnd);
    } catch (e) {
      debugPrint('Error cancelling session end: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_kReminderEnabled) ?? false,
      'hour': prefs.getInt(_kReminderHour) ?? 20,
      'minute': prefs.getInt(_kReminderMinute) ?? 0,
    };
  }
}
