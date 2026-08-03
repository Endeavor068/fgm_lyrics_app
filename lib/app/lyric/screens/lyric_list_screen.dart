import 'dart:async';

import 'package:fgm_lyrics_app/app/favorite/favorite_screen.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/settings/settings_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/app_nav_scope.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/drawer_menu_button.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/language_toggle.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/core/theme/app_fonts.dart';
import 'package:fgm_lyrics_app/core/utils/hymn_search.dart';
import 'package:fgm_lyrics_app/core/utils/image_decode.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom inset so list content clears the scroll-to-top FAB.
const double _kFloatingNavClearance = 24;

class LyricListScreen extends ConsumerStatefulWidget {
  const LyricListScreen({super.key});

  @override
  ConsumerState<LyricListScreen> createState() => _LyricListScreenState();
}

class _LyricListScreenState extends ConsumerState<LyricListScreen> {
  int _tabIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return AppNavScope(
      selectedIndex: _tabIndex,
      onSelect: _onDestinationSelected,
      child: Scaffold(
        body: IndexedStack(
          index: _tabIndex,
          children: const [
            _HymnHomeTab(),
            FavoriteScreen(chromeVisible: true),
            SettingsScreen(chromeVisible: true),
          ],
        ),
      ),
    );
  }
}

class _HymnHomeTab extends ConsumerStatefulWidget {
  const _HymnHomeTab();

  @override
  ConsumerState<_HymnHomeTab> createState() => _HymnHomeTabState();
}

class _HymnHomeTabState extends ConsumerState<_HymnHomeTab> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  final _showScrollToTop = ValueNotifier(false);
  String _query = '';
  Timer? _searchDebounce;

  static const double _scrollToTopThreshold = 280;
  static const _searchDebounceDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScrollPositionChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScrollPositionChanged);
    _scrollController.dispose();
    _showScrollToTop.dispose();
    _searchFocusNode.unfocus();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScrollPositionChanged() {
    if (!_scrollController.hasClients) return;
    final show = _scrollController.offset >= _scrollToTopThreshold;
    if (show != _showScrollToTop.value) {
      _showScrollToTop.value = show;
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    if (_query.isEmpty && _searchController.text.isEmpty) {
      _searchFocusNode.unfocus();
      return;
    }
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _query = '');
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      if (_query.isNotEmpty) setState(() => _query = '');
      return;
    }
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      if (value != _query) setState(() => _query = value);
    });
  }

  Future<void> _scrollToTopAndSearch() async {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      final offset = _scrollController.offset;
      // Longer when farther down so the glide stays gentle, never abrupt.
      final ms = (520 + offset * 0.42).clamp(560, 1400).round();
      await _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: ms),
        curve: Curves.easeInOutCubic,
      );
    }
    if (!mounted) return;
    // Let the scroll settle before opening the keyboard.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    _searchFocusNode.requestFocus();
  }

  Future<void> _pullToRefresh() async {
    ref.invalidate(englishHymnProvider);
    ref.invalidate(frenchHymnProvider);
    await Future.wait([
      ref.read(englishHymnProvider.future),
      ref.read(frenchHymnProvider.future),
    ]).catchError((_) => <List<Lyric>>[]);
  }

  List<Lyric> _filtered(List<Lyric> lyrics, {required bool languageIsEnglish}) {
    final q = _query.trim();
    if (q.isEmpty) return lyrics;

    final english = ref.read(englishHymnProvider).value ?? const <Lyric>[];
    final french = ref.read(frenchHymnProvider).value ?? const <Lyric>[];
    return searchHymns(
      query: q,
      english: english,
      french: french,
      preferredLanguageIsEnglish: languageIsEnglish,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final languageIsEnglish =
        ref.watch(deviceLocaleProvider) == LanguageEnum.en.name;
    final asyncLyrics = languageIsEnglish
        ? ref.watch(englishHymnProvider)
        : ref.watch(frenchHymnProvider);

    final bg = scheme.surface;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _pullToRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  // Brand + search scroll with the list (one continuous page).
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                      child: Column(
                        children: [
                          _BrandHeader(l10n: l10n),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: _kSearchRowHeight,
                                  child: _SearchField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    hint: l10n.searchHint,
                                    onChanged: _onSearchChanged,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              LanguageToggle(
                                subtle: true,
                                height: _kSearchRowHeight,
                                isEnglish: languageIsEnglish,
                                frenchLabel: l10n.languageFrench,
                                englishLabel: l10n.languageEnglish,
                                onSelectFrench: () => ref
                                    .read(deviceLocaleProvider.notifier)
                                    .setLocale(LanguageEnum.fr),
                                onSelectEnglish: () => ref
                                    .read(deviceLocaleProvider.notifier)
                                    .setLocale(LanguageEnum.en),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.allHymnsOffline,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: scheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ...asyncLyrics.when(
                    data: (lyrics) {
                      final items = _filtered(
                        lyrics,
                        languageIsEnglish: languageIsEnglish,
                      );
                      if (items.isEmpty) {
                        return [
                          _HymnListMessageSliver(
                            message: _query.trim().isEmpty
                                ? l10n.couldNotLoadHymns
                                : l10n.noSearchResults,
                          ),
                        ];
                      }
                      return [
                        _HymnListResultsSliver(
                          items: items,
                          onOpen: _clearSearch,
                        ),
                      ];
                    },
                    loading: () => const [_HymnListLoadingSliver()],
                    error: (_, _) => [
                      _HymnListErrorSliver(
                        message: l10n.couldNotLoadHymns,
                        retryLabel: l10n.retry,
                        onRetry: () {
                          ref.invalidate(
                            languageIsEnglish
                                ? englishHymnProvider
                                : frenchHymnProvider,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: _kFloatingNavClearance + bottomInset + 8,
              child: ValueListenableBuilder<bool>(
                valueListenable: _showScrollToTop,
                builder: (context, show, _) {
                  return IgnorePointer(
                    ignoring: !show,
                    child: AnimatedScale(
                      scale: show ? 1 : 0.85,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: show ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: FloatingActionButton.small(
                          heroTag: 'hymn_scroll_to_top',
                          tooltip: l10n.scrollToTopToSearch,
                          onPressed: _scrollToTopAndSearch,
                          child: const Icon(LucideIcons.arrowUp, size: 20),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const DrawerMenuButton(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo2.png',
                width: 36,
                height: 36,
                opacity: const AlwaysStoppedAnimation(0.72),
                cacheWidth: imageCachePx(context, 36),
                cacheHeight: imageCachePx(context, 36),
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.fraunces,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.appBrandTagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

/// Shared height for the list search field + language toggle row.
const double _kSearchRowHeight = 48;

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;

  void _clear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 0,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              minHeight: _kSearchRowHeight,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: _kSearchRowHeight,
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              size: 20,
              color: scheme.onSurface.withValues(alpha: 0.34),
            ),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: l10n.clear,
                    onPressed: _clear,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: _kSearchRowHeight,
                    ),
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.4),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _HymnListLoadingSliver extends StatelessWidget {
  const _HymnListLoadingSliver();

  static const int _itemCount = 8;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, _kFloatingNavClearance),
      sliver: SliverList.separated(
        itemCount: _itemCount,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: scheme.primary.withValues(alpha: 0.10)),
        itemBuilder: (context, index) => const _LyricTileSkeleton(),
      ),
    );
  }
}

/// Placeholder that mirrors [LyricTile] while hymns are loading.
class _LyricTileSkeleton extends StatefulWidget {
  const _LyricTileSkeleton();

  @override
  State<_LyricTileSkeleton> createState() => _LyricTileSkeletonState();
}

class _LyricTileSkeletonState extends State<_LyricTileSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? scheme.onSurface.withValues(alpha: 0.10)
        : scheme.onSurface.withValues(alpha: 0.07);
    final highlight = isDark
        ? scheme.onSurface.withValues(alpha: 0.18)
        : scheme.onSurface.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final color = Color.lerp(base, highlight, _pulse.value)!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBar(
                      width: double.infinity,
                      height: 16,
                      color: color,
                    ),
                    const SizedBox(height: 8),
                    _SkeletonBar(width: 140, height: 11, color: color),
                    const SizedBox(height: 6),
                    _SkeletonBar(width: 96, height: 11, color: color),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _HymnListMessageSliver extends StatelessWidget {
  const _HymnListMessageSliver({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _HymnListErrorSliver extends StatelessWidget {
  const _HymnListErrorSliver({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.cloudOff, size: 48, color: Colors.grey.shade600),
              const Gutter(),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Gutter(),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw),
                label: Text(retryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HymnListResultsSliver extends StatelessWidget {
  const _HymnListResultsSliver({required this.items, required this.onOpen});

  final List<Lyric> items;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, _kFloatingNavClearance),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: scheme.primary.withValues(alpha: 0.10)),
        itemBuilder: (context, index) {
          final lyric = items[index];
          return LyricTile(lyric: lyric, onOpen: onOpen);
        },
      ),
    );
  }
}
