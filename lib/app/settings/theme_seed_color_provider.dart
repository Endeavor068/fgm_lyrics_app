import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preset seed colors for [ColorScheme.fromSeed]. Index is persisted.
const List<Color> kThemeSeedColors = [
  Color(0xFFFF5252),
  Color(0xFFE91E63),
  Color(0xFF9C27B0),
  Color(0xFF673AB7),
  Color(0xFF3F51B5),
  Color(0xFF2196F3),
  Color(0xFF009688),
  Color(0xFF4CAF50),
  Color(0xFFFF9800),
  Color(0xFF795548),
];

final themeSeedIndexProvider = NotifierProvider<ThemeSeedIndexNotifier, int>(
  ThemeSeedIndexNotifier.new,
);

class ThemeSeedIndexNotifier extends Notifier<int> {
  static const String _key = 'theme_seed_preset_index';

  @override
  int build() {
    _load();
    return 0;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final max = kThemeSeedColors.length - 1;
    state = (prefs.getInt(_key) ?? 0).clamp(0, max);
  }

  Future<void> setIndex(int index) async {
    final max = kThemeSeedColors.length - 1;
    final idx = index.clamp(0, max);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, idx);
    state = idx;
  }
}
