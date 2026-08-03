import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Preloads every Google Font used in the app so first paint never waits on
/// a network/cache fetch (UI, hymn body options, and display accents).
abstract final class AppFonts {
  /// Cached family names — avoid calling `GoogleFonts.*()` on list hot paths.
  static final String? ibmPlexSans = GoogleFonts.ibmPlexSans().fontFamily;
  static final String? fraunces = GoogleFonts.fraunces().fontFamily;

  /// Kick off and await font file loads for all app typefaces / common weights.
  static Future<void> preload() async {
    try {
      // Touch styles so google_fonts queues downloads / asset resolution.
      final styles = <TextStyle>[
        // App UI / tab bar / hymn body option
        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w400),
        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
        // Display / hymn titles / default lyric body
        GoogleFonts.fraunces(fontWeight: FontWeight.w400),
        GoogleFonts.fraunces(fontWeight: FontWeight.w600),
        GoogleFonts.fraunces(fontWeight: FontWeight.w700),
        // Optional hymn body fonts (settings)
        GoogleFonts.ebGaramond(fontWeight: FontWeight.w400),
        GoogleFonts.ebGaramond(fontWeight: FontWeight.w700),
        GoogleFonts.lora(fontWeight: FontWeight.w400),
        GoogleFonts.lora(fontWeight: FontWeight.w700),
        GoogleFonts.openSans(fontWeight: FontWeight.w400),
        GoogleFonts.openSans(fontWeight: FontWeight.w600),
      ];

      await GoogleFonts.pendingFonts(styles);
    } catch (e, st) {
      // Never block launch if fonts fail (offline / first install edge cases).
      debugPrint('AppFonts.preload failed: $e\n$st');
    }
  }
}
