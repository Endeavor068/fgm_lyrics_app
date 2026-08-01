import 'package:flutter/material.dart';

/// Fixed brand palette for FGM Hymnals.
///
/// Light: warm sacred brick-red on a soft parchment surface.
/// Dark: softer rose-red accents on a warm near-black surface so contrast
/// stays pleasant without neon glare.
abstract final class AppThemeColors {
  /// Seed for [ColorScheme.fromSeed] in light mode.
  static const Color lightSeed = Color(0xFFB42318);

  /// Seed for [ColorScheme.fromSeed] in dark mode.
  static const Color darkSeed = Color(0xFFE8A598);

  /// Warm parchment background (light).
  static const Color lightScaffold = Color(0xFFFDFBF7);

  /// Warm charcoal background (dark).
  static const Color darkScaffold = Color(0xFF141210);

  static ColorScheme lightScheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: lightSeed,
      brightness: Brightness.light,
    );
    return scheme.copyWith(
      surface: lightScaffold,
      primary: lightSeed,
      onPrimary: Colors.white,
    );
  }

  static ColorScheme darkScheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: darkSeed,
      brightness: Brightness.dark,
    );
    return scheme.copyWith(
      surface: darkScaffold,
      primary: const Color(0xFFE8A598),
      onPrimary: const Color(0xFF3B1410),
    );
  }
}
