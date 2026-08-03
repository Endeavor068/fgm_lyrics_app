import 'package:flutter/material.dart';

/// Hides [child] on scroll with a coordinated fade + slide + height collapse.
///
/// Used for app headers (and similar chrome) so disappearance feels soft rather
/// than an abrupt snap.
class ScrollHideChrome extends StatelessWidget {
  const ScrollHideChrome({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 340),
    this.alignment = Alignment.topCenter,
    this.slideOffset = const Offset(0, -0.2),
  });

  final bool visible;
  final Widget child;
  final Duration duration;
  final Alignment alignment;

  /// Slide direction while hiding. Negative Y = slide up (typical for app bars).
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    final curve = visible ? Curves.easeOutCubic : Curves.easeInCubic;

    return ClipRect(
      child: AnimatedOpacity(
        duration: duration,
        curve: curve,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: duration,
          curve: curve,
          offset: visible ? Offset.zero : slideOffset,
          child: AnimatedAlign(
            duration: duration,
            curve: curve,
            alignment: alignment,
            heightFactor: visible ? 1.0 : 0.0,
            child: child,
          ),
        ),
      ),
    );
  }
}
