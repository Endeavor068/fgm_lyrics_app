import 'package:fgm_lyrics_app/core/models/lyric.dart';
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

/// Tab content: dark preview card + navigation through lyric phrases.
class ProjectionTabContent extends StatefulWidget {
  const ProjectionTabContent({super.key, required this.lyric});

  final Lyric lyric;

  @override
  State<ProjectionTabContent> createState() => _ProjectionTabContentState();
}

class _ProjectionTabContentState extends State<ProjectionTabContent> {
  int _index = 0;

  List<ProjectionSlide> _slides(AppLocalizations l10n) =>
      buildProjectionSlides(widget.lyric, l10n);

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
    final screenH = MediaQuery.sizeOf(context).height;

    if (slides.isEmpty) {
      return Container(
        key: const ValueKey('projection_empty'),
        constraints: BoxConstraints(minHeight: screenH * 0.5),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.projectionEmpty,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    final safeIndex = _index.clamp(0, slides.length - 1);
    final slide = slides[safeIndex];

    return Container(
      key: const ValueKey('projection'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          Text(
            slide.sectionLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
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
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    slide.text,
                    key: ValueKey('preview_$safeIndex'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fraunces(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.projectionFullscreenHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.projectionTapToFullscreen,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: l10n.previousPage,
                onPressed: safeIndex > 0
                    ? () => _goTo(safeIndex - 1, slides.length)
                    : null,
                icon: const Icon(LucideIcons.chevronLeft),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.projectionSlideIndicator(safeIndex + 1, slides.length),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.nextPage,
                onPressed: safeIndex < slides.length - 1
                    ? () => _goTo(safeIndex + 1, slides.length)
                    : null,
                icon: const Icon(LucideIcons.chevronRight),
              ),
            ],
          ),
        ],
      ),
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
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
                        color: Colors.white,
                        fontSize: fontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Tap zones for prev / next without showing chrome.
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
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${slide.sectionLabel}  ·  '
                              '${l10n.projectionSlideIndicator(_index + 1, widget.slides.length)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            tooltip: l10n.closeProjection,
                            onPressed: _close,
                            icon: const Icon(
                              LucideIcons.x,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _index > 0
                                      ? () => _goTo(_index - 1)
                                      : null,
                                  icon: Icon(
                                    LucideIcons.chevronLeft,
                                    size: 36,
                                    color: _index > 0
                                        ? Colors.white70
                                        : Colors.white24,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                IconButton(
                                  onPressed: _index < widget.slides.length - 1
                                      ? () => _goTo(_index + 1)
                                      : null,
                                  icon: Icon(
                                    LucideIcons.chevronRight,
                                    size: 36,
                                    color: _index < widget.slides.length - 1
                                        ? Colors.white70
                                        : Colors.white24,
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
            ],
          ),
        ),
      ),
    );
  }
}
