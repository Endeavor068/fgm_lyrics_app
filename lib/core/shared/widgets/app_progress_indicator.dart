import 'package:flutter/material.dart';

/// App-wide circular progress with rounded stroke ends.
///
/// Prefer this over raw [CircularProgressIndicator] so loading states stay
/// consistent. Theme defaults come from [ProgressIndicatorThemeData].
class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
    this.size,
    this.strokeWidth,
    this.color,
    this.trackColor,
    this.value,
  });

  /// When set, wraps the indicator in a square of this size.
  final double? size;

  /// Overrides [ProgressIndicatorThemeData.strokeWidth].
  final double? strokeWidth;

  /// Overrides the indicator color (defaults to theme primary).
  final Color? color;

  /// Soft track behind the arc. Null uses the theme track when available.
  final Color? trackColor;

  /// Determinate progress `0..1`, or null for indeterminate.
  final double? value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final indicator = CircularProgressIndicator(
      value: value,
      strokeWidth: strokeWidth,
      strokeCap: StrokeCap.round,
      color: color,
      backgroundColor: trackColor ?? scheme.primary.withValues(alpha: 0.14),
    );

    if (size == null) return indicator;

    return SizedBox(width: size, height: size, child: indicator);
  }
}
