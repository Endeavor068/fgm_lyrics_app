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

  /// Builds a [Lyric] from a HarmonyForge hymn and language.
  static Lyric fromHarmonyForge(HarmonyForgeHymn hymn, bool useFrench) {
    final primaryLang = useFrench ? 'fr' : 'en';
    final fallbackLang = useFrench ? 'en' : 'fr';
    final primary = hymn.content[primaryLang];
    final fallback = hymn.content[fallbackLang];
    final c = primary ?? fallback;
    if (c == null) {
      return Lyric(id: hymn.id, contentLanguage: primaryLang);
    }
    final mergedNumber = _firstNonEmpty(primary?.number, fallback?.number);
    final mergedTitle = _firstNonEmpty(primary?.title, fallback?.title);
    final mergedAuthor = _firstNonEmpty(primary?.author, fallback?.author);
    final mergedYear = _firstNonEmpty(primary?.year, fallback?.year);
    final mergedKey = _firstNonEmpty(primary?.key, fallback?.key);
    final mergedChorus = _firstNonEmpty(primary?.chorus, fallback?.chorus);
    final mergedVerses = _firstNonEmptyList(primary?.verses, fallback?.verses);
    final mergedAudio = _firstNonEmpty(primary?.audioUrl, fallback?.audioUrl);
    final mergedPartition = _firstNonEmpty(
      primary?.partitionUrl,
      fallback?.partitionUrl,
    );
    final parsedSongId = _parseInt(mergedNumber, 0);
    final titleFallback = parsedSongId > 0
        ? 'Hymn $parsedSongId'
        : (mergedNumber.isNotEmpty ? 'Hymn $mergedNumber' : 'Untitled');

    return Lyric(
      id: hymn.id,
      songTitle: mergedTitle.isNotEmpty ? mergedTitle : titleFallback,
      songId: parsedSongId,
      chorus: mergedChorus,
      key: mergedKey,
      author: mergedAuthor,
      year: mergedYear,
      enLyrics: mergedVerses,
      audioUrl: mergedAudio,
      partitionUrl: mergedPartition,
      contentLanguage: primaryLang,
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
        other.contentLanguage == contentLanguage;
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
        contentLanguage.hashCode;
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

  static String _firstNonEmpty(String? first, String? second) {
    final firstValue = first?.trim() ?? '';
    if (firstValue.isNotEmpty) return firstValue;
    return second?.trim() ?? '';
  }

  static List<String> _firstNonEmptyList(
    List<String>? first,
    List<String>? second,
  ) {
    final firstList = first ?? const [];
    if (firstList.any((line) => line.trim().isNotEmpty)) {
      return firstList;
    }
    return second ?? const [];
  }
}
