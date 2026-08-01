import 'package:fgm_lyrics_app/app/favorite/favorite_screen.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/language_toggle.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/lyric_tile.dart';
import 'package:fgm_lyrics_app/app/settings/settings_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/hymn_search.dart';
import 'package:fgm_lyrics_app/core/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom inset so list content clears the floating nav bar.
const double _kFloatingNavClearance = 72;

class LyricListScreen extends ConsumerStatefulWidget {
  const LyricListScreen({super.key});

  @override
  ConsumerState<LyricListScreen> createState() => _LyricListScreenState();
}

class _LyricListScreenState extends ConsumerState<LyricListScreen> {
  int _tabIndex = 0;
  bool _chromeVisible = true;

  static const double _scrollHideThreshold = 6;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is! ScrollUpdateNotification) return false;

    final delta = notification.scrollDelta ?? 0;
    if (delta == 0) return false;

    // Always show chrome when the user is at (or overscrolled past) the top.
    if (notification.metrics.pixels <= 0) {
      if (!_chromeVisible) setState(() => _chromeVisible = true);
      return false;
    }

    if (delta > _scrollHideThreshold && _chromeVisible) {
      setState(() => _chromeVisible = false);
    } else if (delta < -_scrollHideThreshold && !_chromeVisible) {
      setState(() => _chromeVisible = true);
    }
    return false;
  }

  void _onTabSelected(int index) {
    setState(() {
      _tabIndex = index;
      _chromeVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScrollNotification,
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const _HymnHomeTab(),
                FavoriteScreen(chromeVisible: _chromeVisible),
                SettingsScreen(chromeVisible: _chromeVisible),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 10 + bottomInset,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 340),
              curve: _chromeVisible ? Curves.easeOutCubic : Curves.easeInCubic,
              offset: _chromeVisible ? Offset.zero : const Offset(0, 0.55),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                curve: _chromeVisible
                    ? Curves.easeOutCubic
                    : Curves.easeInCubic,
                opacity: _chromeVisible ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_chromeVisible,
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withValues(alpha: 0.28),
                    shape: const StadiumBorder(),
                    color: isDark ? scheme.surfaceContainerHigh : Colors.white,
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 6,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth / 3;
                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                left: itemWidth * _tabIndex,
                                width: itemWidth,
                                top: 0,
                                bottom: 0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(
                                        alpha: isDark ? 0.22 : 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _FloatingNavItem(
                                    icon: LucideIcons.house,
                                    label: l10n.navHome,
                                    selected: _tabIndex == 0,
                                    onTap: () => _onTabSelected(0),
                                  ),
                                  _FloatingNavItem(
                                    icon: LucideIcons.star,
                                    label: l10n.navFavorites,
                                    selected: _tabIndex == 1,
                                    onTap: () => _onTabSelected(1),
                                  ),
                                  _FloatingNavItem(
                                    icon: LucideIcons.settings,
                                    label: l10n.navSettings,
                                    selected: _tabIndex == 2,
                                    onTap: () => _onTabSelected(2),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.45);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                scale: selected ? 1.08 : 1.0,
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
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
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  String? _secondaryTitleFor(Lyric lyric) {
    final isEnglish = lyric.contentLanguage == 'en';
    final other = isEnglish
        ? ref.watch(frenchHymnProvider).value
        : ref.watch(englishHymnProvider).value;
    if (other == null) return null;
    final match = other.where((l) => l.id.toString() == lyric.id.toString());
    final title = match.firstOrNull?.songTitle.trim();
    if (title == null || title.isEmpty) return null;
    return title;
  }

  List<Widget> _buildBodySlivers({
    required AppLocalizations l10n,
    required ColorScheme scheme,
    required bool languageIsEnglish,
    required AsyncValue<List<Lyric>> asyncLyrics,
  }) {
    return asyncLyrics.when(
      data: (lyrics) {
        final items = _filtered(lyrics, languageIsEnglish: languageIsEnglish);
        if (items.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _query.trim().isEmpty
                        ? l10n.couldNotLoadHymns
                        : l10n.noSearchResults,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              _kFloatingNavClearance,
            ),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: scheme.outline.withValues(alpha: 0.18),
              ),
              itemBuilder: (context, index) {
                final lyric = items[index];
                return LyricTile(
                  lyric: lyric,
                  secondaryTitle: _secondaryTitleFor(lyric),
                );
              },
            ),
          ),
        ];
      },
      loading: () => [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: AppProgressIndicator()),
        ),
      ],
      error: (err, _) => [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.cloudOff,
                    size: 48,
                    color: Colors.grey.shade600,
                  ),
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
                    icon: const Icon(LucideIcons.refreshCw),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

    return ColoredBox(
      color: bg,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _pullToRefresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: _BrandHeader(l10n: l10n),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedSearchChromeDelegate(
                  searchController: _searchController,
                  hint: l10n.searchHint,
                  onQueryChanged: (value) => setState(() => _query = value),
                  languageIsEnglish: languageIsEnglish,
                  frenchLabel: l10n.languageFrench,
                  englishLabel: l10n.languageEnglish,
                  onSelectFrench: () => ref
                      .read(deviceLocaleProvider.notifier)
                      .setLocale(LanguageEnum.fr),
                  onSelectEnglish: () => ref
                      .read(deviceLocaleProvider.notifier)
                      .setLocale(LanguageEnum.en),
                  backgroundColor: bg,
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
              ..._buildBodySlivers(
                l10n: l10n,
                scheme: scheme,
                languageIsEnglish: languageIsEnglish,
                asyncLyrics: asyncLyrics,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pinned search + language toggle that shrinks to a compact row while scrolling.
class _PinnedSearchChromeDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchChromeDelegate({
    required this.searchController,
    required this.hint,
    required this.onQueryChanged,
    required this.languageIsEnglish,
    required this.frenchLabel,
    required this.englishLabel,
    required this.onSelectFrench,
    required this.onSelectEnglish,
    required this.backgroundColor,
  });

  final TextEditingController searchController;
  final String hint;
  final ValueChanged<String> onQueryChanged;
  final bool languageIsEnglish;
  final String frenchLabel;
  final String englishLabel;
  final VoidCallback onSelectFrench;
  final VoidCallback onSelectEnglish;
  final Color backgroundColor;

  static const double _expandedHeight = 148;
  static const double _collapsedHeight = 56;

  @override
  double get maxExtent => _expandedHeight;

  @override
  double get minExtent => _collapsedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Only the fully-expanded frame shows the stacked layout; any shrink
    // uses the compact row so the Column never lays out in a tight box.
    final compact = shrinkOffset > 0.5;

    return Material(
      color: backgroundColor,
      elevation: overlapsContent || compact ? 0.8 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      child: ClipRect(
        child: SizedBox.expand(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              compact ? 6 : 8,
              20,
              compact ? 6 : 8,
            ),
            child: compact
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _SearchField(
                          controller: searchController,
                          hint: hint,
                          onChanged: onQueryChanged,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      LanguageToggle(
                        compact: true,
                        isEnglish: languageIsEnglish,
                        frenchLabel: frenchLabel,
                        englishLabel: englishLabel,
                        onSelectFrench: onSelectFrench,
                        onSelectEnglish: onSelectEnglish,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SearchField(
                        controller: searchController,
                        hint: hint,
                        onChanged: onQueryChanged,
                      ),
                      const SizedBox(height: 10),
                      LanguageToggle(
                        isEnglish: languageIsEnglish,
                        frenchLabel: frenchLabel,
                        englishLabel: englishLabel,
                        onSelectFrench: onSelectFrench,
                        onSelectEnglish: onSelectEnglish,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchChromeDelegate oldDelegate) {
    return searchController != oldDelegate.searchController ||
        hint != oldDelegate.hint ||
        languageIsEnglish != oldDelegate.languageIsEnglish ||
        frenchLabel != oldDelegate.frenchLabel ||
        englishLabel != oldDelegate.englishLabel ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/logo2.png', width: 36, height: 36),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.appBrandTagline,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.compact = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool compact;

  void _clear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final radius = compact ? 20.0 : 28.0;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: compact ? 14 : 16),
          decoration: InputDecoration(
            hintText: hint,
            isDense: compact,
            prefixIcon: Icon(
              LucideIcons.search,
              size: compact ? 18 : 22,
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
            prefixIconConstraints: compact
                ? const BoxConstraints(minWidth: 40, minHeight: 36)
                : null,
            suffixIcon: hasText
                ? IconButton(
                    tooltip: l10n.clear,
                    onPressed: _clear,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: compact ? 32 : 40,
                      minHeight: compact ? 32 : 40,
                    ),
                    icon: Icon(
                      LucideIcons.x,
                      size: compact ? 16 : 18,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                    ),
                  )
                : null,
            suffixIconConstraints: compact
                ? const BoxConstraints(minWidth: 36, minHeight: 36)
                : null,
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? scheme.surfaceContainerHighest
                : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 8 : 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: BorderSide(color: scheme.primary, width: 1.4),
            ),
          ),
        );
      },
    );
  }
}

/// Kept for callers that still expect a standalone filtered list widget.
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
          color: scheme.outline.withValues(alpha: 0.18),
        );
      },
      itemCount: lyrics.length,
    );
  }
}
