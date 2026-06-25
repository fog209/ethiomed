import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../errors/app_exception.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.withDatabase(ref.watch(databaseProvider));
});

final dailyStudyRemindersEnabledProvider =
    StateNotifierProvider<NotificationReminderNotifier, bool>((ref) {
      return NotificationReminderNotifier(
        ref.watch(notificationServiceProvider),
      );
    });

class NotificationReminderNotifier extends StateNotifier<bool> {
  NotificationReminderNotifier(this._service) : super(false) {
    unawaited(_load());
  }

  final NotificationService _service;

  Future<void> _load() async {
    state = await _service.areDailyRemindersEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await _service.setDailyRemindersEnabled(enabled);
    state = await _service.areDailyRemindersEnabled();
  }
}

class NotificationService {
  NotificationService._({required AppDatabase database}) : _db = database;

  static NotificationService? _instance;

  static const String _enabledKey = 'daily_study_reminders_enabled';
  static const int _notificationId = 4201;
  static const String _payload = 'sm2_due_cards_daily';
  static const String _channelId = 'sm2_due_cards';
  static const String _channelName = 'SM-2 due cards';
  static const String _channelDescription =
      'Daily reminders for spaced-repetition cards due today.';
  static const int _reminderHour = 8;
  static const int _reminderMinute = 0;

  factory NotificationService(AppDatabase db) {
    return _instance ??= NotificationService._(database: db);
  }

  factory NotificationService.withDatabase(AppDatabase database) {
    return NotificationService._(database: database);
  }

  final AppDatabase _db;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      tz.initializeTimeZones();

      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
        ),
      );

      final initialized = await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      if (initialized == false) {
        throw const AppException('Unable to initialize local notifications.');
      }

      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();

      _isInitialized = true;
    } catch (error) {
      debugPrint('Notification initialization error: $error');
      throw AppException('Unable to initialize local notifications.');
    }
  }

  Future<void> scheduleDueReminder(DateTime nextDueAt, int dueCount) async {
    try {
      if (dueCount <= 0 || !(await areDailyRemindersEnabled())) {
        return;
      }

      await initialize();

      final freshDueCount = await countDueCardsForDate(nextDueAt);
      if (freshDueCount <= 0) {
        await cancelDueReminders();
        return;
      }

      await _scheduleDailyReminder(nextDueAt, freshDueCount);
    } catch (error) {
      debugPrint('Unable to schedule due-card reminder: $error');
      throw AppException('Unable to schedule due-card reminder.');
    }
  }

  Future<void> rescheduleDueReminders() async {
    try {
      if (!(await areDailyRemindersEnabled())) {
        return;
      }

      await initialize();

      final nextDueAt = await _nextDueAt();
      if (nextDueAt == null) {
        await cancelDueReminders();
        return;
      }

      final freshDueCount = await countDueCardsForDate(nextDueAt);
      if (freshDueCount <= 0) {
        await cancelDueReminders();
        return;
      }

      await _scheduleDailyReminder(nextDueAt, freshDueCount);
    } catch (error) {
      debugPrint('Unable to reschedule due-card reminders: $error');
      throw AppException('Unable to reschedule due-card reminders.');
    }
  }

  Future<void> setDailyRemindersEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);

      if (enabled) {
        await rescheduleDueReminders();
      } else {
        await cancelAllScheduledNotifications();
      }
    } catch (error) {
      debugPrint('Unable to update daily study reminders: $error');
      throw AppException('Unable to update daily study reminders.');
    }
  }

  Future<bool> areDailyRemindersEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? false;
    } catch (error) {
      debugPrint('Unable to read daily study reminder setting: $error');
      throw AppException('Unable to read daily study reminder setting.');
    }
  }

  Future<int> countDueCardsForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final rows = await _db
          .customSelect(
            '''
            SELECT COUNT(*) AS count
            FROM quiz_table
            WHERE next_due_at IS NULL
               OR (next_due_at >= ? AND next_due_at < ?)
            ''',
            variables: [Variable(startOfDay), Variable(endOfDay)],
          )
          .get();

      if (rows.isEmpty) return 0;
      return rows.single.read<int>('count');
    } catch (error) {
      debugPrint('Unable to count due cards: $error');
      throw AppException('Unable to count due cards.');
    }
  }

  Future<void> cancelDueReminders() async {
    try {
      await initialize();
      await _plugin.cancel(id: _notificationId);
    } catch (error) {
      debugPrint('Unable to cancel due-card reminders: $error');
      throw AppException('Unable to cancel due-card reminders.');
    }
  }

  Future<void> cancelAllScheduledNotifications() async {
    try {
      await initialize();
      await _plugin.cancelAll();
    } catch (error) {
      debugPrint('Unable to cancel scheduled notifications: $error');
      throw AppException('Unable to cancel scheduled notifications.');
    }
  }

  Future<void> _scheduleDailyReminder(DateTime dueAt, int dueCount) async {
    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: _reminderTimeForDueDate(dueAt),
      notificationDetails: _notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      title: 'WardReady',
      body: '📚 You have $dueCount cards due today',
      payload: _payload,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<DateTime?> _nextDueAt() async {
    final now = DateTime.now();
    final rows = await _db
        .customSelect(
          '''
          SELECT next_due_at
          FROM quiz_table
          WHERE next_due_at IS NULL OR next_due_at >= ?
          ORDER BY
            CASE WHEN next_due_at IS NULL THEN 0 ELSE 1 END,
            next_due_at ASC
          LIMIT 1
          ''',
          variables: [Variable(now)],
        )
        .get();

    if (rows.isEmpty) {
      return null;
    }

    return rows.single.read<DateTime?>('next_due_at') ?? now;
  }

  tz.TZDateTime _reminderTimeForDueDate(DateTime dueAt) {
    final dueDate = tz.TZDateTime.from(dueAt, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      _reminderHour,
      _reminderMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    if (response.payload != _payload) {
      return;
    }

    final freshDueCount = await countDueCardsForDate(DateTime.now());
    if (freshDueCount <= 0) {
      await cancelDueReminders();
      return;
    }

    await rescheduleDueReminders();
  }
}
