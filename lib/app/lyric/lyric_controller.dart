import 'package:fgm_lyrics_app/app/lyric/lyric_repository.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FrenchHymn extends AsyncNotifier<List<Lyric>> {
  @override
  Future<List<Lyric>> build() =>
      ref.read(lyricRepositoryProvider).loadFrenchLyrics();
}

final frenchHymnProvider = AsyncNotifierProvider<FrenchHymn, List<Lyric>>(
  FrenchHymn.new,
);

class EnglishHymn extends AsyncNotifier<List<Lyric>> {
  @override
  Future<List<Lyric>> build() =>
      ref.read(lyricRepositoryProvider).loadEnglishLyrics();
}

final englishHymnProvider = AsyncNotifierProvider<EnglishHymn, List<Lyric>>(
  EnglishHymn.new,
);
