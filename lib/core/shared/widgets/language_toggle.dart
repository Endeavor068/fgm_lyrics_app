import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Segmented Français / English control used on the hymn list and detail screens.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.isEnglish,
    required this.frenchLabel,
    required this.englishLabel,
    required this.onSelectFrench,
    required this.onSelectEnglish,
    this.compact = false,
    this.subtle = false,
    this.height,
  });

  final bool isEnglish;
  final String frenchLabel;
  final String englishLabel;
  final VoidCallback onSelectFrench;
  final VoidCallback onSelectEnglish;

  /// Dense pill used in the pinned list header while scrolling.
  final bool compact;

  /// Quiet typographic switch for immersive reading (detail screen).
  final bool subtle;

  /// Height for [subtle] mode. Defaults to 40.
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (subtle) {
      return _SubtleLanguageToggle(
        isEnglish: isEnglish,
        onSelectFrench: onSelectFrench,
        onSelectEnglish: onSelectEnglish,
        height: height ?? 40,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;

    final fr = compact ? 'FR' : frenchLabel;
    final en = compact ? 'EN' : englishLabel;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          _LanguageToggleSegment(
            label: fr,
            selected: !isEnglish,
            compact: compact,
            onTap: onSelectFrench,
          ),
          _LanguageToggleSegment(
            label: en,
            selected: isEnglish,
            compact: compact,
            onTap: onSelectEnglish,
          ),
        ],
      ),
    );
  }
}

class _SubtleLanguageToggle extends StatelessWidget {
  const _SubtleLanguageToggle({
    required this.isEnglish,
    required this.onSelectFrench,
    required this.onSelectEnglish,
    required this.height,
  });

  final bool isEnglish;
  final VoidCallback onSelectFrench;
  final VoidCallback onSelectEnglish;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;
    final muted = scheme.onSurface.withValues(alpha: 0.34);
    final thumb = scheme.primary;
    final radius = height / 2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnglish ? onSelectFrench : onSelectEnglish,
        borderRadius: BorderRadius.circular(radius),
        splashColor: scheme.primary.withValues(alpha: 0.08),
        highlightColor: scheme.primary.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: height >= 46 ? 12 : 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  height: 1,
                  color: isEnglish ? muted : scheme.primary,
                ),
                child: const Text('FR'),
              ),
              SizedBox(width: height >= 46 ? 8 : 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: height >= 46 ? 30 : 26,
                height: height >= 46 ? 17 : 15,
                padding: const EdgeInsets.all(2),
                alignment: isEnglish
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: thumb.withValues(alpha: isDark ? 0.28 : 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: height >= 46 ? 13 : 11,
                  height: height >= 46 ? 13 : 11,
                  decoration: BoxDecoration(
                    color: thumb,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: thumb.withValues(alpha: 0.35),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: height >= 46 ? 8 : 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: height >= 46 ? 12 : 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  height: 1,
                  color: isEnglish ? scheme.primary : muted,
                ),
                child: const Text('EN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageToggleSegment extends StatelessWidget {
  const _LanguageToggleSegment({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final muted = scheme.onSurface.withValues(alpha: 0.34);
    final child = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          vertical: compact ? 6 : 10,
          horizontal: compact ? 10 : 0,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: isDark ? 0.14 : 0.07)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: compact ? 11.5 : 13.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.15,
            color: selected ? scheme.primary : muted,
          ),
        ),
      ),
    );
    return compact ? child : Expanded(child: child);
  }
}
