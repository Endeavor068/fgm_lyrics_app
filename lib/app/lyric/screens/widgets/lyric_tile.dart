import 'package:fgm_lyrics_app/app/lyric/screens/lyric_detail_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricTile extends ConsumerWidget {
  const LyricTile({super.key, required this.lyric});
  final Lyric lyric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () => context.push(LyricDetailScreen(lyric: lyric)),
      minVerticalPadding: 0,
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      leading: Container(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 60),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.music_note_outlined),
      ),
      titleTextStyle: context.textTheme.bodyLarge!.copyWith(),
      title: DefaultTextStyle(
        style: context.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
        ),
        child: Row(
          children: [
            if (lyric.displayNumber.isNotEmpty)
              Text('${lyric.displayNumber}. '),
            Expanded(
              child: Text(
                (lyric.songTitle.trim().isEmpty ? 'Untitled' : lyric.songTitle)
                    .capitalize,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      subtitle: Text(
        (lyric.author.isNotEmpty ? lyric.author : 'N/A'),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
