import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Font size ─────────────────────────────────────────────────────────────────

const double kMinFontSize = 14.0;
const double kMaxFontSize = 28.0;
const double kDefaultFontSize = 18.0;

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(
  FontSizeNotifier.new,
);

class FontSizeNotifier extends Notifier<double> {
  static const String _key = 'lyric_font_size';

  @override
  double build() {
    _load();
    return kDefaultFontSize;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = (prefs.getDouble(_key) ?? kDefaultFontSize).clamp(
      kMinFontSize,
      kMaxFontSize,
    );
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(kMinFontSize, kMaxFontSize);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, clamped);
    state = clamped;
  }
}

// ── Font family ───────────────────────────────────────────────────────────────

/// Curated set of fonts available for hymn text.
enum HymnFontFamily {
  fraunces('Fraunces'),
  ibmPlexSans('IBM Plex Sans'),
  ebGaramond('EB Garamond'),
  lora('Lora'),
  openSans('Open Sans');

  const HymnFontFamily(this.displayName);

  final String displayName;

  /// Returns a [TextStyle] for this font family with the given properties.
  TextStyle textStyle({
    double fontSize = kDefaultFontSize,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.6,
    Color? color,
  }) => switch (this) {
    HymnFontFamily.fraunces => GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    ),
    HymnFontFamily.ibmPlexSans => GoogleFonts.ibmPlexSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    ),
    HymnFontFamily.ebGaramond => GoogleFonts.ebGaramond(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    ),
    HymnFontFamily.lora => GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    ),
    HymnFontFamily.openSans => GoogleFonts.openSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    ),
  };
}

final fontFamilyProvider = NotifierProvider<FontFamilyNotifier, HymnFontFamily>(
  FontFamilyNotifier.new,
);

class FontFamilyNotifier extends Notifier<HymnFontFamily> {
  static const String _key = 'lyric_font_family';

  @override
  HymnFontFamily build() {
    _load();
    return HymnFontFamily.fraunces;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    // Legacy sans options → IBM Plex Sans
    if (saved == 'roboto' || saved == 'inter') {
      state = HymnFontFamily.ibmPlexSans;
      await prefs.setString(_key, HymnFontFamily.ibmPlexSans.name);
      return;
    }
    // Removed font option → default
    if (saved == 'notoSerif') {
      state = HymnFontFamily.fraunces;
      await prefs.setString(_key, HymnFontFamily.fraunces.name);
      return;
    }
    state = HymnFontFamily.values.firstWhere(
      (f) => f.name == saved,
      orElse: () => HymnFontFamily.fraunces,
    );
  }

  Future<void> setFontFamily(HymnFontFamily family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, family.name);
    state = family;
  }
}
