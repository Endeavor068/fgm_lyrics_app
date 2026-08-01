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
  });

  final bool isEnglish;
  final String frenchLabel;
  final String englishLabel;
  final VoidCallback onSelectFrench;
  final VoidCallback onSelectEnglish;

  /// Dense pill used in the pinned list header while scrolling.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? scheme.surfaceContainerHighest
        : const Color(0xFFF3EDE4);

    final fr = compact ? 'FR' : frenchLabel;
    final en = compact ? 'EN' : englishLabel;

    Widget segment({
      required String label,
      required bool selected,
      required VoidCallback onTap,
    }) {
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
                ? (isDark ? scheme.onSurface : const Color(0xFF2A2A2A))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(compact ? 16 : 22),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? (isDark ? scheme.surface : Colors.white)
                  : scheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
      return compact ? child : Expanded(child: child);
    }

    return Container(
      padding: EdgeInsets.all(compact ? 3 : 4),
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(compact ? 18 : 26),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          segment(label: fr, selected: !isEnglish, onTap: onSelectFrench),
          segment(label: en, selected: isEnglish, onTap: onSelectEnglish),
        ],
      ),
    );
  }
}
