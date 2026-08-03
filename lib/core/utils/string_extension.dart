extension StringExtension on String {
  /// Strips HTML tags for plain-text display.
  String get stripHtmlTags =>
      replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();

  /// Splits hymn text into display lines, treating HTML block/break tags as
  /// newlines before stripping remaining markup.
  List<String> get lyricLines {
    final withBreaks =
        replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'<p[^>]*>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'</div\s*>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'<div[^>]*>', caseSensitive: false), '\n')
            .replaceAll(RegExp(r'</li\s*>', caseSensitive: false), '\n');

    return withBreaks.stripHtmlTags
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  String get capitalizeWord {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get minimizeWord => toLowerCase();

  String get capitalize {
    if (trim().isEmpty) return this;
    final RegExp keyWords = RegExp(
      r'\b(?:Jesus|Lord|Jésus|Sauveur|Eternel|Seigneur|Savior|Saviour|God|Dieu|Thee|Thou|Thy|I|Him|Son|His)\b',
      caseSensitive: false,
    );
    final words = split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return this;
    final firstWord = words.first.capitalizeWord;

    final remainingWords = words
        .sublist(1)
        .map(
          (wordInSentence) => wordInSentence.toLowerCase().contains(keyWords)
              ? wordInSentence.capitalizeWord
              : wordInSentence.minimizeWord,
        )
        .join(' ');

    return "$firstWord $remainingWords";
  }
}
