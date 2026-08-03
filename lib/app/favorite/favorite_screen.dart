import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/drawer_menu_button.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/scroll_hide_chrome.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key, this.chromeVisible = true});

  /// When false, the app bar collapses (scroll-hide chrome from parent shell).
  final bool chromeVisible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favorites = ref.watch(favoriteNotifierProvider);
    final viewLanguage = ref.watch(favoriteViewLanguageProvider);
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrollHideChrome(
            visible: chromeVisible,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: NavigationToolbar(
                    centerMiddle: false,
                    leading: const DrawerMenuButton(),
                    middle: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.favoritesTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SegmentedButton<LanguageEnum>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
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
                ),
              ),
            ),
          ),
          Expanded(
            child: AppDefaultSpacing(
              child: favorites.isEmpty
                  ? Center(
                      child: Text(
                        l10n.favoritesEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 72),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final lyric = favorites[index];
                        return LyricTile(lyric: lyric);
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: scheme.outline.withValues(alpha: 0.18),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
