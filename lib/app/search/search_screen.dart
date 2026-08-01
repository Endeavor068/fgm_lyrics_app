import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/lyric_list_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/hymn_search.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Lyric> _filteredLyrics = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _filter() {
    final query = _controller.text.trim();
    final isEnglish = ref.read(deviceLocaleProvider) == LanguageEnum.en.name;
    final english = ref.read(englishHymnProvider).value ?? const <Lyric>[];
    final french = ref.read(frenchHymnProvider).value ?? const <Lyric>[];

    final next = query.isEmpty
        ? (isEnglish ? english : french)
        : searchHymns(
            query: query,
            english: english,
            french: french,
            preferredLanguageIsEnglish: isEnglish,
          );

    if (!mounted) return;
    setState(() => _filteredLyrics = next);
  }

  @override
  void dispose() {
    _controller.removeListener(_filter);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = ref.watch(deviceLocaleProvider) == LanguageEnum.en.name;

    // Refresh results when catalogs become available.
    ref.watch(englishHymnProvider);
    ref.watch(frenchHymnProvider);

    final queryEmpty = _controller.text.trim().isEmpty;
    final results = queryEmpty
        ? (ref
                  .watch(isEnglish ? englishHymnProvider : frenchHymnProvider)
                  .value ??
              _filteredLyrics)
        : _filteredLyrics;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(l10n.searchTitle),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.x),
          ),
        ],
      ),
      body: AppDefaultSpacing(
        child: Column(
          children: [
            const GutterSmall(),
            SearchInputField(
              controller: _controller,
              focusNode: _focusNode,
              hintText: l10n.searchHint,
            ),
            const Gutter(),
            Expanded(child: LyricListView(lyrics: results)),
          ],
        ),
      ),
    );
  }
}

class SearchInputField extends StatelessWidget {
  const SearchInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
            hintText: hintText,
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    tooltip: l10n.clear,
                    onPressed: controller.clear,
                    icon: Icon(
                      LucideIcons.x,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
