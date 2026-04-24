import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/lyric_list_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    // Auto-focus the text field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _filter() {
    final query = _controller.text.toLowerCase();
    final isEnglish = ref.read(deviceLocaleProvider) == LanguageEnum.en.name;
    final allLyrics = isEnglish
        ? ref.read(englishHymnProvider).value ?? []
        : ref.read(frenchHymnProvider).value ?? [];
    setState(() {
      _filteredLyrics = allLyrics
          .where((lyric) => lyric.songTitle.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = ref.watch(deviceLocaleProvider) == LanguageEnum.en.name;
    if (_controller.text.isEmpty) {
      _filteredLyrics =
          ref
              .watch(isEnglish ? englishHymnProvider : frenchHymnProvider)
              .value ??
          [];
    }
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(l10n.searchTitle),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
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
            Expanded(child: LyricListView(lyrics: _filteredLyrics)),
          ],
        ),
      ),
    );
  }
}

class SearchInputField extends StatelessWidget {
  const SearchInputField({
    super.key,
    required TextEditingController controller,
    required FocusNode focusNode,
    required this.hintText,
  }) : _controller = controller,
       _focusNode = focusNode;

  final TextEditingController _controller;
  final FocusNode _focusNode;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
        hintText: hintText,
      ),
    );
  }
}
