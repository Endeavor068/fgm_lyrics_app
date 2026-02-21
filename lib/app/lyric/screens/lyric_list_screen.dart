import 'package:fgm_lyrics_app/app/favorite/favorite_screen.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/app/search/search_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricListScreen extends ConsumerStatefulWidget {
  const LyricListScreen({super.key});
  @override
  ConsumerState<LyricListScreen> createState() => _LyricListScreenState();
}

class _LyricListScreenState extends ConsumerState<LyricListScreen> {
  @override
  void didChangeDependencies() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   WoltModalSheet.show(
    //     context: context,
    //     barrierDismissible: false,
    //     enableDrag: false,
    //     pageListBuilder: (bottomSheetContext) => [
    //       SliverWoltModalSheetPage(
    //         useSafeArea: true,

    //         mainContentSliversBuilder: (context) => [
    //           PayWallScreen(
    //             onTap: () {
    //               WoltModalSheet.of(bottomSheetContext).showNext();
    //             },
    //           ),
    //         ],
    //       ),

    //       SliverWoltModalSheetPage(
    //         leadingNavBarWidget: IconButton.filled(
    //           onPressed: () =>
    //               WoltModalSheet.of(bottomSheetContext).showPrevious(),
    //           icon: const Icon(Icons.arrow_back),
    //         ),
    //         mainContentSliversBuilder: (context) => [
    //           PaymentMethodScreen(
    //             onTap: () {
    //               WoltModalSheet.of(bottomSheetContext).showNext();
    //             },
    //           ),
    //         ],
    //       ),

    //       SliverWoltModalSheetPage(
    //         leadingNavBarWidget: IconButton.filled(
    //           onPressed: () =>
    //               WoltModalSheet.of(bottomSheetContext).showPrevious(),
    //           icon: const Icon(Icons.arrow_back),
    //         ),
    //         mainContentSliversBuilder: (context) => [const PaymentScreen()],
    //       ),
    //     ],
    //   );
    // });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final languageIsEnglish =
        ref.watch(deviceLocaleProvider) == LanguageEnum.en.name;
    final lyrics = languageIsEnglish
        ? ref.watch(englishHymnProvider).requireValue
        : ref.watch(frenchHymnProvider).requireValue;
    final currentLangString = languageIsEnglish ? 'EN' : 'FR';
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
            icon: ref.watch(themeProvider) == ThemeMode.light
                ? const Icon(Icons.dark_mode_rounded)
                : const Icon(Icons.light_mode_rounded),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              context.push(const FavoriteScreen());
            },
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(const SearchScreen()),
          ),
        ],
        title: const Text("FGM Hymns"),
      ),
      body: AppDefaultSpacing(child: LyricListView(lyrics: lyrics)),
    );
  }

  List<Lyric> filterLyrics(List<Lyric>? lyrics, SearchController controller) {
    return lyrics
            ?.where(
              (lyric) => lyric.songTitle.toLowerCase().contains(
                controller.text.toLowerCase(),
              ),
            )
            .toList() ??
        [];
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
