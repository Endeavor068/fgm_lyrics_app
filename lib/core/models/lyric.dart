import 'package:fgm_lyrics_app/core/models/harmony_forge_hymn.dart';
import 'package:flutter/foundation.dart';

/// UI model for a single hymn in one language (used in list and detail screens).
class Lyric {
  const Lyric({
    this.songTitle = '',
    this.songId = 0,
    required this.id,
    this.chorus = '',
    this.key = '',
    this.author = '',
    this.year = '',
    this.enLyrics = const [],
    this.audioUrl = '',
    this.partitionUrl = '',
    this.contentLanguage = 'en',
    this.availableInEn = false,
    this.availableInFr = false,
  });

  final dynamic id;
  final String songTitle;
  final int songId;
  final String chorus;
  final String key;
  final String author;

  /// Composition year from the JSON `year` field (e.g. "1890" or "1851-1936").
  final String year;

  final List<String> enLyrics;
  final String audioUrl;
  final String partitionUrl;

  /// Locale key for this list row (`en` or `fr`). Used for per-language media
  /// cache file names.
  final String contentLanguage;

  /// True when [HarmonyForgeHymn.content] has meaningful English text.
  final bool availableInEn;

  /// True when [HarmonyForgeHymn.content] has meaningful French text.
  final bool availableInFr;

  /// Whether [content] has a non-empty title or at least one non-empty verse.
  static bool hasMeaningfulContent(HarmonyForgeContent? content) {
    if (content == null) return false;
    if (content.title.trim().isNotEmpty) return true;
    return content.verses.any((line) => line.trim().isNotEmpty);
  }

  /// Builds a [Lyric] from a HarmonyForge hymn and language.
  ///
  /// Title, verses, chorus, and metadata come from the **primary** language
  /// only (no silent cross-language text fallback). Audio / partition URLs may
  /// still fall back to the other language when the primary omits them.
  static Lyric fromHarmonyForge(HarmonyForgeHymn hymn, bool useFrench) {
    final primaryLang = useFrench ? 'fr' : 'en';
    final fallbackLang = useFrench ? 'en' : 'fr';
    final primary = hymn.content[primaryLang];
    final fallback = hymn.content[fallbackLang];
    final hasEn = hasMeaningfulContent(hymn.content['en']);
    final hasFr = hasMeaningfulContent(hymn.content['fr']);

    if (primary == null) {
      return Lyric(
        id: hymn.id,
        contentLanguage: primaryLang,
        availableInEn: hasEn,
        availableInFr: hasFr,
      );
    }

    final number = primary.number.trim();
    final title = primary.title.trim();
    final author = primary.author.trim();
    final year = primary.year.trim();
    final key = primary.key.trim();
    final chorus = primary.chorus.trim();
    final verses = primary.verses;
    final audio = _firstNonEmpty(primary.audioUrl, fallback?.audioUrl);
    final partition = _firstNonEmpty(
      primary.partitionUrl,
      fallback?.partitionUrl,
    );
    final parsedSongId = _parseInt(number, 0);
    final titleFallback = parsedSongId > 0
        ? 'Hymn $parsedSongId'
        : (number.isNotEmpty ? 'Hymn $number' : 'Untitled');

    return Lyric(
      id: hymn.id,
      songTitle: title.isNotEmpty ? title : titleFallback,
      songId: parsedSongId,
      chorus: chorus,
      key: key,
      author: author,
      year: year,
      enLyrics: verses,
      audioUrl: audio,
      partitionUrl: partition,
      contentLanguage: primaryLang,
      availableInEn: hasEn,
      availableInFr: hasFr,
    );
  }

  Lyric copyWith({
    String? songTitle,
    int? songId,
    dynamic id,
    String? chorus,
    String? key,
    String? author,
    String? year,
    List<String>? enLyrics,
    String? audioUrl,
    String? partitionUrl,
    String? contentLanguage,
    bool? availableInEn,
    bool? availableInFr,
  }) {
    return Lyric(
      songTitle: songTitle ?? this.songTitle,
      songId: songId ?? this.songId,
      id: id ?? this.id,
      chorus: chorus ?? this.chorus,
      key: key ?? this.key,
      author: author ?? this.author,
      year: year ?? this.year,
      enLyrics: enLyrics ?? this.enLyrics,
      audioUrl: audioUrl ?? this.audioUrl,
      partitionUrl: partitionUrl ?? this.partitionUrl,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      availableInEn: availableInEn ?? this.availableInEn,
      availableInFr: availableInFr ?? this.availableInFr,
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    final text = value.toString().trim();
    if (text.isEmpty) return fallback;
    final direct = int.tryParse(text);
    if (direct != null) return direct;
    final firstDigits = RegExp(r'\d+').firstMatch(text)?.group(0);
    return firstDigits != null
        ? int.tryParse(firstDigits) ?? fallback
        : fallback;
  }

  @override
  String toString() {
    return 'Lyric(songTitle: $songTitle, songId: $songId, id: $id, ...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lyric &&
        other.songTitle == songTitle &&
        other.songId == songId &&
        other.id == id &&
        other.chorus == chorus &&
        other.key == key &&
        other.author == author &&
        other.year == year &&
        listEquals(other.enLyrics, enLyrics) &&
        other.contentLanguage == contentLanguage &&
        other.availableInEn == availableInEn &&
        other.availableInFr == availableInFr;
  }

  @override
  int get hashCode {
    return songTitle.hashCode ^
        songId.hashCode ^
        id.hashCode ^
        chorus.hashCode ^
        key.hashCode ^
        author.hashCode ^
        year.hashCode ^
        enLyrics.hashCode ^
        contentLanguage.hashCode ^
        availableInEn.hashCode ^
        availableInFr.hashCode;
  }

  /// Composition year for display.
  ///
  /// Returns the dedicated [year] field when populated; otherwise extracts the
  /// first 4-digit year found in [author] (e.g. "Russell Kelso Carter (1891)"
  /// → "1891"). Returns an empty string when no year can be determined.
  String get displayYear {
    if (year.isNotEmpty) return year;
    final match = RegExp(r'\b([12][0-9]{3})\b').firstMatch(author);
    return match?.group(1) ?? '';
  }

  /// Human-friendly number shown in UI.
  /// Returns empty string when no numeric number exists.
  String get displayNumber {
    if (songId > 0) return songId.toString();
    final idText = id?.toString().trim() ?? '';
    return RegExp(r'^\d+$').hasMatch(idText) ? idText : '';
  }

  /// Whether this hymn has a counterpart in the other language.
  bool get hasOtherLanguage {
    if (contentLanguage == 'fr') return availableInEn;
    return availableInFr;
  }

  static String _firstNonEmpty(String? first, String? second) {
    final firstValue = first?.trim() ?? '';
    if (firstValue.isNotEmpty) return firstValue;
    return second?.trim() ?? '';
  }
}
