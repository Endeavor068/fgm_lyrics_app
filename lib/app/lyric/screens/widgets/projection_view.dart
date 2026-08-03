import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// One projection slide: up to two lyric lines for a verse or chorus section.
class ProjectionSlide {
  const ProjectionSlide({required this.text, required this.sectionLabel});

  final String text;
  final String sectionLabel;
}

/// Builds projection slides from [lyric], pairing consecutive lines (2 per slide).
List<ProjectionSlide> buildProjectionSlides(
  Lyric lyric,
  AppLocalizations l10n,
) {
  final slides = <ProjectionSlide>[];

  void addSection(String label, String raw) {
    final lines = raw.lyricLines;
    if (lines.isEmpty) return;

    for (var i = 0; i < lines.length; i += 2) {
      final chunk = i + 1 < lines.length
          ? '${lines[i]}\n${lines[i + 1]}'
          : lines[i];
      slides.add(ProjectionSlide(text: chunk, sectionLabel: label));
    }
  }

  final verses = lyric.enLyrics;
  if (verses.isNotEmpty) {
    addSection(l10n.verseLabel(1), verses.first);
  }

  final chorus = lyric.chorus.stripHtmlTags;
  if (chorus.isNotEmpty) {
    addSection(l10n.chorusSectionLabel, lyric.chorus);
  }

  for (var i = 1; i < verses.length; i++) {
    addSection(l10n.verseLabel(i + 1), verses[i]);
  }

  return slides;
}

/// Tab content: staged preview card + navigation through lyric phrases.
class ProjectionTabContent extends StatefulWidget {
  const ProjectionTabContent({super.key, required this.lyric});

  final Lyric lyric;

  @override
  State<ProjectionTabContent> createState() => _ProjectionTabContentState();
}

class _ProjectionTabContentState extends State<ProjectionTabContent> {
  int _index = 0;
  List<ProjectionSlide>? _cachedSlides;
  Object? _slidesCacheKey;

  List<ProjectionSlide> _slides(AppLocalizations l10n) {
    final key = Object.hash(
      widget.lyric.id,
      widget.lyric.contentLanguage,
      widget.lyric.chorus,
      widget.lyric.enLyrics.length,
      l10n.localeName,
    );
    if (_cachedSlides != null && _slidesCacheKey == key) {
      return _cachedSlides!;
    }
    _slidesCacheKey = key;
    _cachedSlides = buildProjectionSlides(widget.lyric, l10n);
    return _cachedSlides!;
  }

  @override
  void didUpdateWidget(covariant ProjectionTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lyric.id != widget.lyric.id ||
        oldWidget.lyric.contentLanguage != widget.lyric.contentLanguage) {
      _cachedSlides = null;
      _slidesCacheKey = null;
      _index = 0;
    }
  }

  void _goTo(int index, int total) {
    if (total == 0) return;
    setState(() => _index = index.clamp(0, total - 1));
  }

  Future<void> _openFullscreen(List<ProjectionSlide> slides) async {
    if (slides.isEmpty) return;
    final result = await Navigator.of(context).push<int>(
      PageRouteBuilder<int>(
        opaque: true,
        pageBuilder: (_, _, _) =>
            ProjectionFullscreenPage(slides: slides, initialIndex: _index),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    if (result != null && mounted) {
      setState(() => _index = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _slides(l10n);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenH = MediaQuery.sizeOf(context).height;

    if (slides.isEmpty) {
      return _ProjectionEmptyState(minHeight: screenH * 0.5);
    }

    final safeIndex = _index.clamp(0, slides.length - 1);
    final slide = slides[safeIndex];
    const radius = 26.0;
    // Fixed stage height — never grows/shrinks with slide text length.
    final stageHeight = (screenH * 0.42).clamp(280.0, 420.0);

    return Padding(
      key: const ValueKey('projection'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        children: [
          _ProjectionSectionChip(label: slide.sectionLabel),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _openFullscreen(slides),
            onHorizontalDragEnd: (details) {
              final vx = details.primaryVelocity ?? 0;
              if (vx < -200) {
                _goTo(safeIndex + 1, slides.length);
              } else if (vx > 200) {
                _goTo(safeIndex - 1, slides.length);
              }
            },
            child: Material(
              elevation: 10,
              shadowColor: Colors.black.withValues(alpha: isDark ? 0.55 : 0.22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius),
              ),
              color: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: double.infinity,
                height: stageHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: scheme.primary.withValues(
                        alpha: isDark ? 0.28 : 0.16,
                      ),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF221A17),
                        Color(0xFF100E0C),
                        Color(0xFF1A1210),
                      ],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.primary.withValues(alpha: 0.12),
                                scheme.primary,
                                scheme.primary.withValues(alpha: 0.12),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 28, 28, 44),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [...previousChildren, ?currentChild],
                              );
                            },
                            child: FittedBox(
                              key: ValueKey('preview_$safeIndex'),
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width - 88,
                                ),
                                child: Text(
                                  slide.text,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fraunces(
                                    color: const Color(0xFFF7F1EA),
                                    fontSize: 28,
                                    height: 1.42,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.maximize2,
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.projectionTapToFullscreen,
                                style: GoogleFonts.ibmPlexSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.projectionFullscreenHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.42),
            ),
          ),
          const SizedBox(height: 18),
          _ProjectionNavBar(
            current: safeIndex + 1,
            total: slides.length,
            onPrevious: safeIndex > 0
                ? () => _goTo(safeIndex - 1, slides.length)
                : null,
            onNext: safeIndex < slides.length - 1
                ? () => _goTo(safeIndex + 1, slides.length)
                : null,
            previousTooltip: l10n.previousPage,
            nextTooltip: l10n.nextPage,
            indicator: l10n.projectionSlideIndicator(
              safeIndex + 1,
              slides.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionEmptyState extends StatelessWidget {
  const _ProjectionEmptyState({required this.minHeight});

  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const ValueKey('projection_empty'),
      constraints: BoxConstraints(minHeight: minHeight),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: scheme.primary.withValues(alpha: isDark ? 0.28 : 0.12),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2C231F), Color(0xFF181412)]
                : const [Color(0xFFFFFCF9), Color(0xFFF8EDE6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.16),
                      scheme.primary.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  LucideIcons.presentation,
                  color: scheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.projectionEmpty,
                textAlign: TextAlign.center,
                style: GoogleFonts.fraunces(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: scheme.onSurface.withValues(alpha: 0.78),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectionSectionChip extends StatelessWidget {
  const _ProjectionSectionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: scheme.primary.withValues(alpha: isDark ? 0.28 : 0.14),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }
}

class _ProjectionNavBar extends StatelessWidget {
  const _ProjectionNavBar({
    required this.current,
    required this.total,
    required this.onPrevious,
    required this.onNext,
    required this.previousTooltip,
    required this.nextTooltip,
    required this.indicator,
  });

  final int current;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String previousTooltip;
  final String nextTooltip;
  final String indicator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final track = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProjectionNavButton(
            tooltip: previousTooltip,
            icon: LucideIcons.chevronLeft,
            onPressed: onPrevious,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  indicator,
                  style: GoogleFonts.ibmPlexSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                if (total > 1) ...[
                  const SizedBox(height: 6),
                  _ProjectionDots(current: current, total: total),
                ],
              ],
            ),
          ),
          _ProjectionNavButton(
            tooltip: nextTooltip,
            icon: LucideIcons.chevronRight,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _ProjectionNavButton extends StatelessWidget {
  const _ProjectionNavButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Material(
      color: enabled
          ? scheme.primary.withValues(alpha: 0.12)
          : scheme.onSurface.withValues(alpha: 0.04),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}

class _ProjectionDots extends StatelessWidget {
  const _ProjectionDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxDots = total.clamp(1, 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxDots, (i) {
        final active =
            (current - 1) == i ||
            (total > 8 && i == maxDots - 1 && current > 8);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(right: i == maxDots - 1 ? 0 : 4),
          width: active ? 12 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active
                ? scheme.primary
                : scheme.primary.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

/// Immersive black-screen projection for a video projector / large display.
class ProjectionFullscreenPage extends StatefulWidget {
  const ProjectionFullscreenPage({
    super.key,
    required this.slides,
    this.initialIndex = 0,
  });

  final List<ProjectionSlide> slides;
  final int initialIndex;

  @override
  State<ProjectionFullscreenPage> createState() =>
      _ProjectionFullscreenPageState();
}

class _ProjectionFullscreenPageState extends State<ProjectionFullscreenPage> {
  late int _index;
  bool _chromeVisible = true;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.slides.length - 1);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _goTo(int index) {
    setState(() => _index = index.clamp(0, widget.slides.length - 1));
  }

  void _close() => Navigator.of(context).pop(_index);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slide = widget.slides[_index];
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.shortestSide * 0.07).clamp(28.0, 64.0);
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070605),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _chromeVisible = !_chromeVisible),
          onHorizontalDragEnd: (details) {
            final vx = details.primaryVelocity ?? 0;
            if (vx < -200) {
              _goTo(_index + 1);
            } else if (vx > 200) {
              _goTo(_index - 1);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 1.15,
                    colors: [Color(0xFF1A1210), Color(0xFF070605)],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.08,
                  vertical: size.height * 0.1,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      slide.text,
                      key: ValueKey('fs_$_index'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fraunces(
                        color: const Color(0xFFF7F1EA),
                        fontSize: fontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: size.width * 0.28,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_index > 0) {
                      _goTo(_index - 1);
                    } else {
                      setState(() => _chromeVisible = !_chromeVisible);
                    }
                  },
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: size.width * 0.28,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (_index < widget.slides.length - 1) {
                      _goTo(_index + 1);
                    } else {
                      setState(() => _chromeVisible = !_chromeVisible);
                    }
                  },
                ),
              ),
              AnimatedOpacity(
                opacity: _chromeVisible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_chromeVisible,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                '${slide.sectionLabel}  ·  '
                                '${l10n.projectionSlideIndicator(_index + 1, widget.slides.length)}',
                                style: GoogleFonts.ibmPlexSans(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4, top: 2),
                            child: IconButton(
                              tooltip: l10n.closeProjection,
                              onPressed: _close,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                              icon: Icon(
                                LucideIcons.x,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _index > 0
                                        ? () => _goTo(_index - 1)
                                        : null,
                                    icon: Icon(
                                      LucideIcons.chevronLeft,
                                      size: 30,
                                      color: _index > 0
                                          ? scheme.primary
                                          : Colors.white24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: _index < widget.slides.length - 1
                                        ? () => _goTo(_index + 1)
                                        : null,
                                    icon: Icon(
                                      LucideIcons.chevronRight,
                                      size: 30,
                                      color: _index < widget.slides.length - 1
                                          ? scheme.primary
                                          : Colors.white24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
