import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LanguageEnum { en, fr }

final deviceLocaleProvider = NotifierProvider<DeviceLocaleNotifier, String>(
  DeviceLocaleNotifier.new,
);

class DeviceLocaleNotifier extends Notifier<String> {
  @override
  String build() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return code == LanguageEnum.fr.name
        ? LanguageEnum.fr.name
        : LanguageEnum.en.name;
  }
  void changeLocale() {
    state = state == LanguageEnum.en.name
        ? LanguageEnum.fr.name
        : LanguageEnum.en.name;
    debugPrint('locale: $state');
  }
}
