import 'package:fgm_lyrics_app/core/models/lyric.dart';

/// Normalizes text for search: lowercase, strip HTML, fold accents, collapse
/// punctuation/whitespace.
String normalizeForSearch(String input) {
  final plain = input
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .toLowerCase();

  final folded = _foldDiacritics(plain);
  return folded
      .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _foldDiacritics(String input) {
  const from =
      'àáâãäåāăąçćčđďèéêëēĕėęěğìíîïīįłñńňòóôõöōőøřśšşțťùúûüūůűýÿžźż'
      'ÀÁÂÃÄÅĀĂĄÇĆČĐĎÈÉÊËĒĔĖĘĚĞÌÍÎÏĪĮŁÑŃŇÒÓÔÕÖŌŐØŘŚŠŞȚŤÙÚÛÜŪŮŰÝŸŽŹŻ';
  const to =
      'aaaaaaaaacccddeeeeeeeeegiiiiiiilnnnoooooooorsssttuuuuuuuyyzzz'
      'aaaaaaaacccddeeeeeeeeegiiiiiiilnnnoooooooorsssttuuuuuuuyyzzz';

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final index = from.indexOf(ch);
    buffer.write(index >= 0 ? to[index] : ch);
  }
  return buffer.toString();
}

/// Builds a searchable haystack for one hymn version.
String lyricSearchHaystack(Lyric lyric) {
  final parts = <String>[
    lyric.songTitle,
    lyric.author,
    lyric.displayNumber,
    lyric.chorus,
    ...lyric.enLyrics,
  ];
  return normalizeForSearch(parts.join(' '));
}

/// Relevance score for [query] against one [lyric] version. `0` = no match.
int scoreLyricMatch(Lyric lyric, String normalizedQuery, List<String> words) {
  if (normalizedQuery.isEmpty) return 0;

  final title = normalizeForSearch(lyric.songTitle);
  final author = normalizeForSearch(lyric.author);
  final number = normalizeForSearch(lyric.displayNumber);
  final body = normalizeForSearch([lyric.chorus, ...lyric.enLyrics].join(' '));
  final haystack = '$title $author $number $body';

  // Every query word must appear somewhere (AND).
  if (words.any((w) => !haystack.contains(w))) return 0;

  var score = 0;

  if (number.isNotEmpty &&
      (number == normalizedQuery || words.any((w) => number == w))) {
    score += 200;
  }
  if (title.contains(normalizedQuery)) score += 120;
  if (author.contains(normalizedQuery)) score += 50;
  if (body.contains(normalizedQuery)) score += 80;

  for (final word in words) {
    if (title.contains(word)) score += 15;
    if (author.contains(word)) score += 6;
    if (number.contains(word)) score += 25;
    if (body.contains(word)) score += 10;
  }

  // Slight boost for denser / earlier title hits.
  final titleIndex = title.indexOf(normalizedQuery);
  if (titleIndex == 0) score += 20;
  if (titleIndex > 0) score += 8;

  return score;
}

/// Cross-language hymn search.
///
/// Searches title, author, number, verses and chorus in **both** English and
/// French catalogs. Returns the language version that best matches [query]
/// (so an English lyric snippet finds the English hymn even if the UI is FR).
List<Lyric> searchHymns({
  required String query,
  required List<Lyric> english,
  required List<Lyric> french,
  bool preferredLanguageIsEnglish = true,
}) {
  final normalizedQuery = normalizeForSearch(query);
  if (normalizedQuery.isEmpty) {
    return preferredLanguageIsEnglish ? english : french;
  }

  final words = normalizedQuery
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList(growable: false);

  final byId = <String, ({Lyric? en, Lyric? fr})>{};

  void index(Lyric lyric, {required bool isEnglish}) {
    final key = lyric.id.toString();
    final existing = byId[key];
    if (existing == null) {
      byId[key] = isEnglish ? (en: lyric, fr: null) : (en: null, fr: lyric);
    } else {
      byId[key] = isEnglish
          ? (en: lyric, fr: existing.fr)
          : (en: existing.en, fr: lyric);
    }
  }

  for (final lyric in english) {
    index(lyric, isEnglish: true);
  }
  for (final lyric in french) {
    index(lyric, isEnglish: false);
  }

  final scored = <({Lyric lyric, int score})>[];

  for (final pair in byId.values) {
    final enScore = pair.en == null
        ? 0
        : scoreLyricMatch(pair.en!, normalizedQuery, words);
    final frScore = pair.fr == null
        ? 0
        : scoreLyricMatch(pair.fr!, normalizedQuery, words);

    if (enScore <= 0 && frScore <= 0) continue;

    late final Lyric chosen;
    if (enScore > frScore) {
      chosen = pair.en!;
    } else if (frScore > enScore) {
      chosen = pair.fr!;
    } else {
      // Tie: prefer UI language, then whichever exists.
      if (preferredLanguageIsEnglish) {
        chosen = pair.en ?? pair.fr!;
      } else {
        chosen = pair.fr ?? pair.en!;
      }
    }

    scored.add((lyric: chosen, score: enScore > frScore ? enScore : frScore));
  }

  scored.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final aNum = int.tryParse(a.lyric.displayNumber) ?? 1 << 30;
    final bNum = int.tryParse(b.lyric.displayNumber) ?? 1 << 30;
    return aNum.compareTo(bNum);
  });

  return scored.map((e) => e.lyric).toList(growable: false);
}
