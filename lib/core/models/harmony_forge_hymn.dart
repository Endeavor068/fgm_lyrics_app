/// One hymn in the HarmonyForge export format.
///
/// Root export is a JSON array of these. Each item has bilingual content
/// under [content] with keys "en" and "fr". [HarmonyForgeContent] holds
/// per-locale [partitionUrl] and [audioUrl].
///
/// Older payloads may still define root-level `partitionUrl` / `audioUrl`;
/// [fromJson] copies those into each locale when that locale omits the field.
class HarmonyForgeHymn {
  const HarmonyForgeHymn({required this.id, required this.content});

  final String id;
  final Map<String, HarmonyForgeContent> content;

  factory HarmonyForgeHymn.fromJson(Map<String, dynamic> json) {
    final legacyPartition = (json['partitionUrl']?.toString() ?? '').trim();
    final legacyAudio = (json['audioUrl']?.toString() ?? '').trim();
    final contentRaw = json['content'];
    final Map<String, HarmonyForgeContent> content = {};
    if (contentRaw is Map<String, dynamic>) {
      for (final entry in contentRaw.entries) {
        if (entry.value is! Map<String, dynamic>) continue;
        final m = Map<String, dynamic>.from(entry.value as Map);
        final p = (m['partitionUrl']?.toString() ?? '').trim();
        final a = (m['audioUrl']?.toString() ?? '').trim();
        if (legacyPartition.isNotEmpty && p.isEmpty) {
          m['partitionUrl'] = legacyPartition;
        }
        if (legacyAudio.isNotEmpty && a.isEmpty) {
          m['audioUrl'] = legacyAudio;
        }
        content[entry.key] = HarmonyForgeContent.fromJson(m);
      }
    }
    return HarmonyForgeHymn(id: json['id']?.toString() ?? '', content: content);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

/// Language-specific content for one hymn (en or fr).
class HarmonyForgeContent {
  const HarmonyForgeContent({
    this.number = '',
    this.title = '',
    this.author = '',
    this.chorus = '',
    this.year = '',
    this.key = '',
    this.verses = const [],
    this.partitionUrl = '',
    this.audioUrl = '',
  });

  final String number;
  final String title;
  final String author;
  final String chorus;
  final String year;

  /// Musical key (e.g. "C major" / "Do majeur").
  final String key;

  final List<String> verses;

  /// Direct URL to the sheet music file for this language (PDF, image, etc.).
  final String partitionUrl;

  /// Direct URL to the audio recording for this language.
  final String audioUrl;

  factory HarmonyForgeContent.fromJson(Map<String, dynamic> json) {
    final versesRaw = json['verses'];
    return HarmonyForgeContent(
      number: json['number']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      chorus: json['chorus']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      verses: versesRaw is List
          ? List<String>.from(versesRaw.map((e) => e?.toString() ?? ''))
          : const [],
      partitionUrl: json['partitionUrl']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'author': author,
      'chorus': chorus,
      'year': year,
      'key': key,
      'verses': verses,
      'partitionUrl': partitionUrl,
      'audioUrl': audioUrl,
    };
  }
}
