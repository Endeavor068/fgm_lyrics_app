extension StringExtension on String {
  /// Strips HTML tags so the string can be used in plain-text contexts
  /// such as share sheets or notifications.
  String get stripHtmlTags =>
      replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();

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
