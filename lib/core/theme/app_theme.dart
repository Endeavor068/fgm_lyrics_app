import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Builds the light/dark [ThemeData] for FGM Hymnals.
///
/// Soft parchment surfaces, brick-red accents, light typography — matching
/// the detail tab bar and language toggle.
abstract final class AppTheme {
  static const double _radius = 20;
  static const double _controlHeight = 48;

  static ThemeData light({required TextTheme textTheme, String? fontFamily}) {
    final scheme = AppThemeColors.lightScheme();
    return _build(
      brightness: Brightness.light,
      scheme: scheme,
      scaffold: AppThemeColors.lightScaffold,
      textTheme: textTheme,
      fontFamily: fontFamily,
      track: AppThemeColors.lightTrack,
      borderAlpha: 0.12,
    );
  }

  static ThemeData dark({required TextTheme textTheme, String? fontFamily}) {
    final scheme = AppThemeColors.darkScheme();
    return _build(
      brightness: Brightness.dark,
      scheme: scheme,
      scaffold: AppThemeColors.darkScaffold,
      textTheme: textTheme,
      fontFamily: fontFamily,
      track: AppThemeColors.darkTrack(scheme),
      borderAlpha: 0.22,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffold,
    required TextTheme textTheme,
    required String? fontFamily,
    required Color track,
    required double borderAlpha,
  }) {
    final borderColor = scheme.primary.withValues(alpha: borderAlpha);
    final muted = scheme.onSurface.withValues(alpha: 0.38);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
    );
    final labelStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.15,
    );

    final filledStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.08);
        }
        return scheme.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.32);
        }
        return scheme.onPrimary;
      }),
      overlayColor: WidgetStatePropertyAll(
        scheme.onPrimary.withValues(alpha: 0.08),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(64, _controlHeight)),
      shape: WidgetStatePropertyAll(shape),
      textStyle: WidgetStatePropertyAll(labelStyle),
      iconSize: const WidgetStatePropertyAll(18),
    );

    final outlinedStyle = ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(track),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.32);
        }
        return scheme.primary;
      }),
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.06),
      ),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: scheme.onSurface.withValues(alpha: 0.1));
        }
        return BorderSide(color: borderColor);
      }),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      ),
      minimumSize: const WidgetStatePropertyAll(Size(64, _controlHeight)),
      shape: WidgetStatePropertyAll(shape),
      textStyle: WidgetStatePropertyAll(labelStyle),
      iconSize: const WidgetStatePropertyAll(18),
    );

    final textStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: 0.3);
        }
        return scheme.primary;
      }),
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.06),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      textStyle: WidgetStatePropertyAll(
        labelStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      shape: WidgetStatePropertyAll(shape),
    );

    OutlineInputBorder outline([Color? color, double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: color ?? borderColor, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: track,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: borderColor),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.primary.withValues(alpha: 0.10),
        space: 1,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: scheme.onSurface.withValues(alpha: 0.7),
          size: 22,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: filledStyle),
      filledButtonTheme: FilledButtonThemeData(style: filledStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedStyle),
      textButtonTheme: TextButtonThemeData(style: textStyle),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            scheme.onSurface.withValues(alpha: 0.65),
          ),
          overlayColor: WidgetStatePropertyAll(
            scheme.primary.withValues(alpha: 0.08),
          ),
          shape: const WidgetStatePropertyAll(CircleBorder()),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 3,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: track,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: muted,
          fontWeight: FontWeight.w500,
          fontSize: 14.5,
        ),
        prefixIconColor: muted,
        suffixIconColor: scheme.onSurface.withValues(alpha: 0.45),
        border: outline(),
        enabledBorder: outline(),
        disabledBorder: outline(scheme.onSurface.withValues(alpha: 0.08)),
        focusedBorder: outline(scheme.primary, 1.4),
        errorBorder: outline(scheme.error.withValues(alpha: 0.55)),
        focusedErrorBorder: outline(scheme.error, 1.4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.onSurface.withValues(alpha: 0.45);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.28);
          }
          return track;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary.withValues(alpha: 0.2);
          }
          return borderColor;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.14),
        thumbColor: scheme.primary,
        overlayColor: scheme.primary.withValues(alpha: 0.12),
        trackHeight: 3.5,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: track,
        selectedColor: scheme.primary.withValues(alpha: 0.14),
        disabledColor: scheme.onSurface.withValues(alpha: 0.06),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface.withValues(alpha: 0.7),
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: borderColor),
        ),
        side: BorderSide(color: borderColor),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primary.withValues(alpha: 0.14);
            }
            return track;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return scheme.primary;
            return muted;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: borderColor)),
          textStyle: WidgetStatePropertyAll(
            labelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scaffold,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: borderColor),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF2A221F)
            : const Color(0xFF2A2A2A),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: scheme.primary.withValues(
          alpha: brightness == Brightness.dark ? 0.18 : 0.14,
        ),
        strokeWidth: 3.25,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
