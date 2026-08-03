import 'package:flutter/widgets.dart';

/// Decode size in physical pixels for [Image] `cacheWidth` / `cacheHeight`.
///
/// Pass the **display** logical size so Flutter does not keep a full-res bitmap
/// for small logos / watermarks.
int imageCachePx(BuildContext context, double logicalPx) {
  final dpr = MediaQuery.devicePixelRatioOf(context);
  return (logicalPx * dpr).round().clamp(1, 4096);
}
