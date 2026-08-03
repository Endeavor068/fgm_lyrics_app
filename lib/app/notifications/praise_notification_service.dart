import 'dart:io';

import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/notifications/praise_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local praise reminders: once per day, message varies by calendar day.
class PraiseNotificationService {
  PraiseNotificationService._();
  static final PraiseNotificationService instance =
      PraiseNotificationService._();

  static const String prefsEnabledKey = 'praise_reminders_enabled';
  static const String _localePrefsKey = 'device_locale';

  static const int _hour = 5;
  static const int _minute = 0;
  static const int _daysAhead = 21;

  /// Legacy ID range (morning+evening) — cancelled for cleanup.
  static const int _legacyIdCount = 28;

  /// ID space reserved for daily praise reminders.
  static const int _idBase = 4100;

  /// Channel id bumped so existing installs pick up high importance
  /// (Android never updates importance on an already-created channel).
  static const String _channelId = 'praise_reminders_v2';
  static const String _channelName = 'Praise reminders';
  static const String _channelDescription = 'Daily reminders to praise God';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    tzdata.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    // Drop legacy low-importance channel if present.
    await android?.deleteNotificationChannel(channelId: 'praise_reminders');
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        // High = heads-up banner even while the app is in the foreground.
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  /// Heads-up / banner details so the alert is visible while the app is open.
  NotificationDetails _detailsFor(String body) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(body),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      ),
    );
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Douala'));
      } catch (_) {
        // Keep package default.
      }
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsEnabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsEnabledKey, enabled);
    if (enabled) {
      await scheduleReminders();
    } else {
      await cancelReminders();
    }
  }

  /// Call on app start (and after locale change) to keep the schedule fresh.
  Future<void> syncSchedule() async {
    if (!await isEnabled()) {
      await cancelReminders();
      return;
    }
    await scheduleReminders();
  }

  Future<bool> requestPermissionIfNeeded() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> cancelReminders() async {
    if (!_initialized) await init();
    // Clear current + legacy morning/evening IDs.
    const count = _daysAhead > _legacyIdCount ? _daysAhead : _legacyIdCount;
    for (var i = 0; i < count; i++) {
      await _plugin.cancel(id: _idBase + i);
    }
  }

  /// TEMP: immediate notification for manual QA — remove after testing.
  Future<void> showTestNotification() async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    final granted = await requestPermissionIfNeeded();
    if (!granted) return;

    final french = await _isFrenchLocale();
    final message = _messageForDay(DateTime.now());
    final body = message.bodyFor(french);

    await _plugin.show(
      id: _idBase + 999,
      title: message.titleFor(french),
      body: body,
      notificationDetails: _detailsFor(body),
    );
  }

  Future<void> scheduleReminders() async {
    if (kIsWeb) return;
    if (!_initialized) await init();

    await requestPermissionIfNeeded();
    await cancelReminders();

    final french = await _isFrenchLocale();
    final now = tz.TZDateTime.now(tz.local);

    for (var day = 0; day < _daysAhead; day++) {
      final date = now.add(Duration(days: day));
      final when = _occurrenceIfFuture(
        baseDay: date,
        hour: _hour,
        minute: _minute,
        now: now,
      );
      if (when == null) continue;

      final message = _messageForDay(when);
      final body = message.bodyFor(french);

      await _plugin.zonedSchedule(
        id: _idBase + day,
        title: message.titleFor(french),
        body: body,
        scheduledDate: when,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: _detailsFor(body),
      );
    }
  }

  /// Stable day-based pick so each calendar day gets a different message.
  PraiseMessage _messageForDay(DateTime day) {
    final dayIndex = DateTime(
      day.year,
      day.month,
      day.day,
    ).difference(DateTime.utc(2020, 1, 1)).inDays;
    final index = dayIndex.abs() % kPraiseMessages.length;
    return kPraiseMessages[index];
  }

  tz.TZDateTime? _occurrenceIfFuture({
    required DateTime baseDay,
    required int hour,
    required int minute,
    required tz.TZDateTime now,
  }) {
    final scheduled = tz.TZDateTime(
      tz.local,
      baseDay.year,
      baseDay.month,
      baseDay.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) return null;
    return scheduled;
  }

  Future<bool> _isFrenchLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localePrefsKey);
    if (saved == LanguageEnum.fr.name) return true;
    if (saved == LanguageEnum.en.name) return false;
    return resolveDeviceLanguageCode() == LanguageEnum.fr.name;
  }
}
