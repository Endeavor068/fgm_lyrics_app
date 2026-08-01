import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguageEnum { en, fr }

final deviceLocaleProvider = NotifierProvider<DeviceLocaleNotifier, String>(
  DeviceLocaleNotifier.new,
);

class DeviceLocaleNotifier extends Notifier<String> {
  static const _prefsKey = 'device_locale';

  @override
  String build() {
    _load();
    final code = PlatformDispatcher.instance.locale.languageCode;
    return code == LanguageEnum.fr.name
        ? LanguageEnum.fr.name
        : LanguageEnum.en.name;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == LanguageEnum.en.name || saved == LanguageEnum.fr.name) {
      state = saved!;
    }
  }

  Future<void> setLocale(LanguageEnum language) async {
    state = language.name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.name);
    debugPrint('locale: $state');
  }

  void changeLocale() {
    setLocale(
      state == LanguageEnum.en.name ? LanguageEnum.fr : LanguageEnum.en,
    );
  }
}
