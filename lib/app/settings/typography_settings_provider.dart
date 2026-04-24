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
  ebGaramond('EB Garamond'),
  lora('Lora'),
  roboto('Roboto'),
  openSans('Open Sans'),
  notoSerif('Noto Serif');

  const HymnFontFamily(this.displayName);

  final String displayName;

  /// Returns a [TextStyle] for this font family with the given properties.
  TextStyle textStyle({
    double fontSize = kDefaultFontSize,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.6,
    Color? color,
  }) => switch (this) {
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
    HymnFontFamily.roboto => GoogleFonts.roboto(
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
    HymnFontFamily.notoSerif => GoogleFonts.notoSerif(
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
    return HymnFontFamily.ebGaramond;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    state = HymnFontFamily.values.firstWhere(
      (f) => f.name == saved,
      orElse: () => HymnFontFamily.ebGaramond,
    );
  }

  Future<void> setFontFamily(HymnFontFamily family) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, family.name);
    state = family;
  }
}
