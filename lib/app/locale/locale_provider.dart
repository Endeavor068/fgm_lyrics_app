import 'dart:async';

import 'package:fgm_lyrics_app/app/notifications/praise_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguageEnum { en, fr }

/// Best matching app language from the device locale preference list.
///
/// Walks [PlatformDispatcher.locales] so a device whose primary language is
/// unsupported (e.g. German) but lists French second still opens in French.
String resolveDeviceLanguageCode() {
  for (final locale in PlatformDispatcher.instance.locales) {
    final code = locale.languageCode.toLowerCase();
    if (code == LanguageEnum.fr.name) return LanguageEnum.fr.name;
    if (code == LanguageEnum.en.name) return LanguageEnum.en.name;
  }
  return LanguageEnum.en.name;
}

final deviceLocaleProvider = NotifierProvider<DeviceLocaleNotifier, String>(
  DeviceLocaleNotifier.new,
);

class DeviceLocaleNotifier extends Notifier<String> {
  static const _prefsKey = 'device_locale';

  @override
  String build() {
    _load();
    // First frame / first install: follow the device language.
    return resolveDeviceLanguageCode();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    // Only override when the user has explicitly chosen a language.
    if (saved == LanguageEnum.en.name || saved == LanguageEnum.fr.name) {
      state = saved!;
    }
  }

  Future<void> setLocale(LanguageEnum language) async {
    state = language.name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.name);
    debugPrint('locale: $state');
    // Refresh scheduled reminder language.
    unawaited(PraiseNotificationService.instance.syncSchedule());
  }

  void changeLocale() {
    setLocale(
      state == LanguageEnum.en.name ? LanguageEnum.fr : LanguageEnum.en,
    );
  }
}
