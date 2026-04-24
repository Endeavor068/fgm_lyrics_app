import 'package:fgm_lyrics_app/app/favorite/favorite_screen.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/app/search/search_screen.dart';
import 'package:fgm_lyrics_app/app/settings/settings_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LyricListScreen extends ConsumerStatefulWidget {
  const LyricListScreen({super.key});
  @override
  ConsumerState<LyricListScreen> createState() => _LyricListScreenState();
}

class _LyricListScreenState extends ConsumerState<LyricListScreen> {
  /// Used by the pull-to-refresh gesture to reload both language providers.
  Future<void> _pullToRefresh() async {
    ref.invalidate(englishHymnProvider);
    ref.invalidate(frenchHymnProvider);
    await Future.wait([
      ref.read(englishHymnProvider.future),
      ref.read(frenchHymnProvider.future),
    ]).catchError((_) => <List<Lyric>>[]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageIsEnglish =
        ref.watch(deviceLocaleProvider) == LanguageEnum.en.name;
    final asyncLyrics = languageIsEnglish
        ? ref.watch(englishHymnProvider)
        : ref.watch(frenchHymnProvider);
    final currentLangString = languageIsEnglish ? 'FR' : 'EN';
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Text(currentLangString),
            onPressed: () {
              ref.read(deviceLocaleProvider.notifier).changeLocale();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () => context.push(const FavoriteScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(const SearchScreen()),
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push(const SettingsScreen()),
          ),
        ],
        title: Row(
          children: [
            Image.asset('assets/logo2.png', width: 32, height: 32),
            Text(
              l10n.hymnalsTitle,
              style: TextStyle(
                fontSize: 22,
                fontFamily: GoogleFonts.roboto().fontFamily,
              ),
            ),
          ],
        ),
      ),
      body: AppDefaultSpacing(
        child: asyncLyrics.when(
          data: (lyrics) => RefreshIndicator(
            onRefresh: _pullToRefresh,
            child: LyricListView(lyrics: lyrics),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade600),
                  const Gutter(),
                  Text(
                    l10n.couldNotLoadHymns,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Gutter(),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        languageIsEnglish
                            ? englishHymnProvider
                            : frenchHymnProvider,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LyricListView extends StatelessWidget {
  const LyricListView({super.key, required this.lyrics});

  final List<Lyric> lyrics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final lyric = lyrics[index];
        return LyricTile(lyric: lyric);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const GutterSmall();
      },
      itemCount: lyrics.length,
    );
  }
}
