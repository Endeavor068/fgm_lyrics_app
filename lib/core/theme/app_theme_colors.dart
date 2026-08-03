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

  /// Soft control track used by inputs, chips, and segmented controls (light).
  /// Semi-transparent so it sits lightly on the parchment scaffold.
  static const Color lightTrack = Color(0x66F0E9DF);

  /// Soft control track for dark mode.
  static Color darkTrack(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.045);

  static ColorScheme lightScheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: lightSeed,
      brightness: Brightness.light,
    );
    return scheme.copyWith(
      surface: lightScaffold,
      primary: lightSeed,
      onPrimary: Colors.white,
      secondaryContainer: lightSeed.withValues(alpha: 0.12),
      onSecondaryContainer: lightSeed,
      surfaceContainerHighest: lightTrack,
    );
  }

  static ColorScheme darkScheme() {
    const primary = Color(0xFFE8A598);
    final scheme = ColorScheme.fromSeed(
      seedColor: darkSeed,
      brightness: Brightness.dark,
    );
    return scheme.copyWith(
      surface: darkScaffold,
      primary: primary,
      onPrimary: const Color(0xFF3B1410),
      secondaryContainer: primary.withValues(alpha: 0.22),
      onSecondaryContainer: primary,
    );
  }
}
