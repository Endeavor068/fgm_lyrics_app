import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoriteNotifierProvider);
    final viewLanguage = ref.watch(favoriteViewLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: SegmentedButton<LanguageEnum>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                segments: const [
                  ButtonSegment<LanguageEnum>(
                    value: LanguageEnum.en,
                    label: Text('EN'),
                  ),
                  ButtonSegment<LanguageEnum>(
                    value: LanguageEnum.fr,
                    label: Text('FR'),
                  ),
                ],
                selected: {viewLanguage},
                onSelectionChanged: (Set<LanguageEnum> selected) {
                  ref
                      .read(favoriteViewLanguageProvider.notifier)
                      .setLanguage(selected.first);
                },
              ),
            ),
          ),
        ],
      ),
      body: AppDefaultSpacing(
        child: favorites.isEmpty
            ? Center(
                child: Text(
                  l10n.favoritesEmpty,
                  textAlign: TextAlign.center,
                ),
              )
            : ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final lyric = favorites[index];
                  return LyricTile(lyric: lyric);
                },
                separatorBuilder: (context, index) {
                  return Divider(color: Colors.black.withAlpha(20));
                },
              ),
      ),
    );
  }
}
