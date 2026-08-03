import 'package:fgm_lyrics_app/app/notifications/praise_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final praiseRemindersProvider = NotifierProvider<PraiseRemindersNotifier, bool>(
  PraiseRemindersNotifier.new,
);

class PraiseRemindersNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    state = await PraiseNotificationService.instance.isEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await PraiseNotificationService.instance.setEnabled(enabled);
  }
}
