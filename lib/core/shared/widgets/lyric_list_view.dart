import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/lyric_tile.dart';
import 'package:flutter/material.dart';

/// Standalone filtered hymn list (e.g. search results).
class LyricListView extends StatelessWidget {
  const LyricListView({super.key, required this.lyrics});

  final List<Lyric> lyrics;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final lyric = lyrics[index];
        return LyricTile(lyric: lyric);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1,
          color: scheme.primary.withValues(alpha: 0.10),
        );
      },
      itemCount: lyrics.length,
    );
  }
}
