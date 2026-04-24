import 'dart:async';
import 'dart:io';
import 'dart:math' show min;
import 'dart:typed_data';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/harmonyforge/harmonyforge_media_service.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/hymn_text_display.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';
import 'package:synchronized/synchronized.dart';

/// Human-readable message for each [MediaDownloadFailure].
String _failureMessage(AppLocalizations l10n, MediaDownloadFailure failure) =>
    switch (failure) {
      MediaDownloadFailure.noUrl => l10n.errorNoFileForHymn,
      MediaDownloadFailure.invalidUrl => l10n.errorInvalidDownloadLink,
      MediaDownloadFailure.noInternet => l10n.errorNoInternet,
      MediaDownloadFailure.forbidden => l10n.errorDownloadForbidden,
      MediaDownloadFailure.notFound => l10n.errorFileNotFound,
      MediaDownloadFailure.serverError => l10n.errorDownloadFailed,
    };

class LyricDetailScreen extends ConsumerStatefulWidget {
  final Lyric lyric;
  const LyricDetailScreen({super.key, required this.lyric});

  @override
  ConsumerState<LyricDetailScreen> createState() => _LyricDetailScreenState();
}

class _LyricDetailScreenState extends ConsumerState<LyricDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _audioPlayer = AudioPlayer();
  final _sharePlus = SharePlus.instance;
  int _selectedTabIndex = 0;
  bool _audioFileAvailable = false;

  /// Non-null once audio is available locally (downloaded or cached).
  String? _localAudioPath;

  /// Non-null once the partition PDF has been downloaded locally.
  String? _localPartitionPath;

  bool _audioDownloading = false;
  bool _partitionDownloading = false;

  String _getAssetAudioSource() => 'songs/${widget.lyric.id}.mp3';

  Future<bool> _assetAudioExists() async {
    try {
      await DefaultAssetBundle.of(
        context,
      ).load('assets/${_getAssetAudioSource()}');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  Future<void> _checkAudioAndPartitionAvailability() async {
    final media = ref.read(harmonyForgeMediaServiceProvider);
    final fromAssets = await _assetAudioExists();
    final localAudio = await media.getLocalAudioPath(
      widget.lyric.songId,
      widget.lyric.contentLanguage,
    );
    final localPartition = await media.getLocalPartitionPath(
      widget.lyric.songId,
      widget.lyric.contentLanguage,
    );
    if (!mounted) return;
    setState(() {
      _audioFileAvailable = fromAssets || localAudio != null;
      _localAudioPath = localAudio;
      _localPartitionPath = localPartition;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAudioAndPartitionAvailability();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Favorite key: id can be int (e.g. 1) or string (e.g. "160A").
  String get _favoriteIdKey => widget.lyric.id.toString();

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  /// Handles a FAB tap: plays from local if cached, downloads then plays
  /// if only a remote URL is available, or plays from a bundled asset.
  Future<void> _handleAudioFabTap() async {
    if (_localAudioPath != null) {
      await _playOrPauseAudio();
    } else if (widget.lyric.audioUrl.isNotEmpty) {
      await _downloadThenPlayAudio();
    } else if (_audioFileAvailable) {
      await _playOrPauseAudio();
    }
  }

  /// Plays or pauses from the already-resolved local / asset source.
  ///
  /// If the local file is corrupt (playback fails), it is deleted and
  /// the download flow is triggered automatically when a remote URL is set.
  Future<void> _playOrPauseAudio() async {
    if (!_animationController.isCompleted) {
      _animationController.forward();
      try {
        final source = _localAudioPath != null
            ? DeviceFileSource(_localAudioPath!) as Source
            : AssetSource(_getAssetAudioSource());
        await _audioPlayer.play(source);
      } catch (e) {
        debugPrint('Error playing audio: $e');
        _animationController.reverse();
        if (_localAudioPath != null) {
          await _deleteCorruptAudio();
          if (widget.lyric.audioUrl.isNotEmpty) {
            if (mounted) {
              _showSnackBar(
                AppLocalizations.of(context)!.corruptFileRedownloading,
              );
            }
            await _downloadThenPlayAudio();
            return;
          }
        }
        if (mounted) {
          _showSnackBar(AppLocalizations.of(context)!.audioCouldNotPlay);
        }
      }
    } else {
      await _audioPlayer.pause();
      _animationController.reverse();
    }
  }

  Future<void> _deleteCorruptAudio() async {
    try {
      final path = _localAudioPath;
      if (path != null) await File(path).delete();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _localAudioPath = null;
        _audioFileAvailable = false;
      });
    }
  }

  /// Downloads the audio file, caches it locally, then starts playback.
  Future<void> _downloadThenPlayAudio() async {
    setState(() => _audioDownloading = true);
    try {
      final path = await ref
          .read(harmonyForgeMediaServiceProvider)
          .downloadAudio(
            widget.lyric.songId,
            widget.lyric.audioUrl,
            widget.lyric.contentLanguage,
          );
      if (!mounted) return;
      setState(() {
        _localAudioPath = path;
        _audioFileAvailable = true;
        _audioDownloading = false;
      });
      await _playOrPauseAudio();
    } on MediaDownloadException catch (e) {
      if (!mounted) return;
      setState(() => _audioDownloading = false);
      _showSnackBar(_failureMessage(AppLocalizations.of(context)!, e.failure));
    } catch (_) {
      if (!mounted) return;
      setState(() => _audioDownloading = false);
      _showSnackBar(AppLocalizations.of(context)!.downloadFailedGeneric);
    }
  }

  /// Downloads the partition and caches it locally for inline viewing.
  Future<void> _downloadThenOpenPartition() async {
    setState(() => _partitionDownloading = true);
    try {
      final path = await ref
          .read(harmonyForgeMediaServiceProvider)
          .downloadPartition(
            widget.lyric.songId,
            widget.lyric.partitionUrl,
            widget.lyric.contentLanguage,
          );
      if (!mounted) return;
      setState(() {
        _localPartitionPath = path;
        _partitionDownloading = false;
      });
    } on MediaDownloadException catch (e) {
      if (!mounted) return;
      setState(() => _partitionDownloading = false);
      _showSnackBar(_failureMessage(AppLocalizations.of(context)!, e.failure));
    } catch (_) {
      if (!mounted) return;
      setState(() => _partitionDownloading = false);
      _showSnackBar(AppLocalizations.of(context)!.downloadFailedGeneric);
    }
  }

  /// Returns true when [path] points to an image file (PNG / JPG / WEBP).
  bool _isImagePartition(String path) {
    final ext = path.split('.').last.toLowerCase();
    return const {'png', 'jpg', 'jpeg', 'webp'}.contains(ext);
  }

  bool _isPdfPartition(String path) =>
      path.split('.').last.toLowerCase() == 'pdf';

  /// Opens a locally cached partition in an external app (unsupported formats
  /// only — PDF and images use the in-app viewers in [_buildSheetMusicContent]).
  Future<void> _openPartitionExternally(String path) async {
    if (_isImagePartition(path) || _isPdfPartition(path)) return;
    final result = await OpenFile.open(path);
    if (result.type != ResultType.done && mounted) {
      _showSnackBar(
        AppLocalizations.of(context)!.couldNotOpenFile(result.message),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await ref
          .read(favoriteNotifierProvider.notifier)
          .toggleFavorite(widget.lyric.id);
    } catch (e) {
      debugPrint('Error toggling favorite: ${e.toString()}');
    } finally {
      ref.invalidate(isFavoriteProvider(_favoriteIdKey));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFavorite = ref.watch(isFavoriteProvider(_favoriteIdKey));
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            expandedHeight: context.height * 0.2,
            actions: [
              IconButton(
                icon: ref.watch(themeProvider) == ThemeMode.light
                    ? const Icon(Icons.dark_mode_rounded)
                    : const Icon(Icons.light_mode_rounded),
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              ),

              IconButton(
                onPressed: () {
                  _sharePlus.share(
                    ShareParams(
                      text: hymnText,
                      subject:
                          '${widget.lyric.songTitle.capitalize}'
                          '${l10n.shareSubjectSuffix}',
                    ),
                  );
                },
                icon: const Icon(Icons.ios_share_rounded),
              ),
              IconButton(
                onPressed: () async {
                  await _toggleFavorite();
                },
                icon: Icon(
                  isFavorite.value ?? false
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: const [
                StretchMode.blurBackground,
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    "assets/logo2.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.onPrimary,
                      );
                    },
                  ),
                  // Blur overlay
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Content with box shadow effect
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.lyric.displayNumber.isNotEmpty)
                              Text(
                                "${widget.lyric.displayNumber}. ",
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  shadows: [
                                    Shadow(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            FittedBox(
                              child: Text(
                                widget.lyric.songTitle.capitalize,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  shadows: [
                                    Shadow(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // // Author
                        if (widget.lyric.author.isNotEmpty)
                          Text(
                            widget.lyric.author,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withValues(alpha: 0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                        const Gutter(),
                        // Metadata Section
                        _buildMetadataGrid(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Persistent Tab Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              lyricsLabel: l10n.lyricsTab,
              sheetMusicLabel: l10n.sheetMusicTab,
              selectedIndex: _selectedTabIndex,
              onTabSelected: (index) =>
                  setState(() => _selectedTabIndex = index),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Content below tabs
                _buildTabContentSwitcher(),
              ]),
            ),
          ),
        ],
      ),

      floatingActionButton: _buildAudioFab(context),
    );
  }

  /// Returns a FAB for audio, or null when neither a local file nor a remote
  /// URL is available (nothing to play or download).
  Widget? _buildAudioFab(BuildContext context) {
    final hasLocal = _localAudioPath != null || _audioFileAvailable;
    final hasRemote = widget.lyric.audioUrl.isNotEmpty;
    if (!hasLocal && !hasRemote) return null;

    final isReady = hasLocal && !_audioDownloading;
    final isDownloading = _audioDownloading;

    return FloatingActionButton(
      heroTag: 'lyric_detail_fab',
      backgroundColor: isDownloading
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.primary,
      onPressed: isDownloading ? null : _handleAudioFabTap,
      child: isDownloading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : isReady
          ? AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _animationController,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            )
          : Icon(
              Icons.download_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 28,
            ),
    );
  }

  Widget _buildMetadataGrid() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.composedLabel,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const GutterTiny(),
              Text(
                widget.lyric.displayYear.isNotEmpty
                    ? widget.lyric.displayYear
                    : l10n.notAvailable,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.keyLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const GutterTiny(),
              Text(
                widget.lyric.key.isNotEmpty
                    ? widget.lyric.key
                    : l10n.notAvailable,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabContentSwitcher() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: _selectedTabIndex == 0
          ? _buildLyricsContent()
          : _buildSheetMusicContent(),
    );
  }

  Widget _buildLyricsContent() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const ValueKey('lyrics'),
      constraints: BoxConstraints(
        minHeight: context.height,
        minWidth: context.width,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // First verse or all lyrics
          if (widget.lyric.enLyrics.isNotEmpty)
            LyricItem(index: 1, verse: widget.lyric.enLyrics.first),

          // Chorus if exists
          if (widget.lyric.chorus.isNotEmpty) ...[
            const Gutter(),
            Text(
              l10n.chorusLabel,
              style: GoogleFonts.ebGaramond().copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                decoration: TextDecoration.underline,
              ),
            ),
            const GutterSmall(),
            HymnTextDisplay(
              text: widget.lyric.chorus,
              fontWeight: FontWeight.bold,
              lineHeight: 1.6,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ],

          // Additional verses
          if (widget.lyric.enLyrics.length > 1)
            ...widget.lyric.enLyrics.skip(1).map((verse) {
              final index = widget.lyric.enLyrics.indexOf(verse);
              return Column(
                children: [
                  const SizedBox(height: 20),
                  LyricItem(verse: verse, index: index + 1),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSheetMusicContent() {
    final l10n = AppLocalizations.of(context)!;
    final path = _localPartitionPath;
    final hasLocal = path != null;
    final hasRemote = widget.lyric.partitionUrl.isNotEmpty;

    // Image partitions (PNG / JPG / WEBP) are rendered inline.
    if (hasLocal && _isImagePartition(path)) {
      return _PartitionImageView(
        key: ValueKey('sheet_music_image_$path'),
        path: path,
      );
    }

    // PDF partitions: in-app viewer (pinch zoom, page scroll).
    if (hasLocal && _isPdfPartition(path)) {
      return _PartitionPdfView(
        key: ValueKey('sheet_music_pdf_$path'),
        path: path,
      );
    }

    // Fallback: show action card (download or open unknown format externally).
    final leadingIcon = hasLocal
        ? Icons.picture_as_pdf_rounded
        : Icons.music_note_rounded;
    final leadingColor = hasLocal
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;

    return Container(
      constraints: BoxConstraints(
        minHeight: context.height,
        minWidth: context.width,
      ),
      key: const ValueKey('sheet_music'),
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: context.height * 0.12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(leadingIcon, size: 64, color: leadingColor),
          const SizedBox(height: 16),
          Text(
            l10n.sheetMusicHeading,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const GutterSmall(),
          Text(
            hasLocal
                ? l10n.partitionSavedLocal
                : hasRemote
                ? l10n.partitionTapDownload
                : l10n.partitionNone,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasLocal || hasRemote) ...[
            const SizedBox(height: 24),
            if (_partitionDownloading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else
              FilledButton.icon(
                onPressed: hasLocal
                    ? () => _openPartitionExternally(path)
                    : _downloadThenOpenPartition,
                icon: Icon(
                  hasLocal ? Icons.open_in_new_rounded : Icons.download_rounded,
                ),
                label: Text(hasLocal ? l10n.openExternally : l10n.download),
              ),
          ],
        ],
      ),
    );
  }

  String get hymnText {
    final l10n = AppLocalizations.of(context)!;
    final numberPrefix = widget.lyric.displayNumber.isNotEmpty
        ? "${widget.lyric.displayNumber}.  "
        : '';
    final firstVerse = widget.lyric.enLyrics.first.stripHtmlTags;
    final chorus = widget.lyric.chorus.stripHtmlTags;
    final chorusLabel = widget.lyric.chorus.isNotEmpty
        ? (ref.watch(deviceLocaleProvider) == LanguageEnum.en.name
              ? l10n.shareChorusPrefix
              : l10n.shareRefrainPrefix)
        : '';
    final remainingVerses = widget.lyric.enLyrics.length > 1
        ? widget.lyric.enLyrics
              .sublist(1, widget.lyric.enLyrics.length - 1)
              .map((v) => '${v.stripHtmlTags.trim()}\n\n')
              .join(' ')
        : '';
    return '*$numberPrefix${widget.lyric.songTitle.stripHtmlTags}*\n\n'
        '$firstVerse\n\n\n'
        '${chorus.isNotEmpty ? '$chorusLabel$chorus\n\n\n' : ''}'
        '$remainingVerses';
  }
}

class LyricItem extends StatelessWidget {
  const LyricItem({super.key, required this.verse, required this.index});

  final String verse;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index.',
            style: GoogleFonts.ebGaramond().copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Gutter(),
          Expanded(child: HymnTextDisplay(text: verse, lineHeight: 1.6)),
        ],
      ),
    );
  }
}

/// Renders a locally cached image partition (PNG / JPG / WEBP) with
/// pinch-to-zoom and double-tap reset via [InteractiveViewer].
class _PartitionImageView extends StatelessWidget {
  const _PartitionImageView({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Reserve most of the visible screen for the image. Using a concrete
    // height avoids the "Expanded inside unbounded Column" layout error that
    // occurs when this widget is placed inside a SliverList.
    final screenH = MediaQuery.sizeOf(context).height;
    final viewerHeight = screenH * 0.78;
    final fabClearance = screenH * 0.12;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.pinchToZoom,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          SizedBox(
            height: viewerHeight,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.couldNotDisplayImage),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: fabClearance),
        ],
      ),
    );
  }
}

/// In-app PDF viewer: native [PageView] (e-book style swipe), one rasterized
/// page at a time. Pinch-zoom uses [InteractiveViewer] with pan only when
/// zoomed, so horizontal swipes change pages reliably (unlike PhotoViewGallery
/// inside pdfx [PdfView]).
class _PartitionPdfView extends StatefulWidget {
  const _PartitionPdfView({super.key, required this.path});

  final String path;

  @override
  State<_PartitionPdfView> createState() => _PartitionPdfViewState();
}

class _PartitionPdfViewState extends State<_PartitionPdfView> {
  final PageController _pageController = PageController();
  final Lock _renderLock = Lock();
  final Map<String, Uint8List> _bitmapCache = {};
  final Map<String, Future<Uint8List?>> _bitmapFutureCache = {};

  PdfDocument? _document;
  Object? _openError;
  int _pageCount = 0;

  /// Current page, 1-based (for UI / indicators).
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _openPdf();
  }

  Future<void> _openPdf() async {
    try {
      final doc = await PdfDocument.openFile(widget.path);
      if (!mounted) {
        await doc.close();
        return;
      }
      setState(() {
        _document = doc;
        _pageCount = doc.pagesCount;
        _openError = null;
        _currentPage = 1;
      });
    } catch (e) {
      if (mounted) setState(() => _openError = e);
    }
  }

  Future<Uint8List?> _bitmapForPage(int index, int maxPixelsW, int maxPixelsH) {
    final key = '$index-$maxPixelsW-$maxPixelsH';
    return _bitmapFutureCache.putIfAbsent(
      key,
      () => _renderPageToBytes(index, maxPixelsW, maxPixelsH),
    );
  }

  Future<Uint8List?> _renderPageToBytes(
    int index,
    int maxPixelsW,
    int maxPixelsH,
  ) async {
    final doc = _document;
    if (doc == null) return null;
    final key = '$index-$maxPixelsW-$maxPixelsH';
    final cached = _bitmapCache[key];
    if (cached != null) return cached;

    return _renderLock.synchronized(() async {
      final again = _bitmapCache[key];
      if (again != null) return again;

      PdfPage? page;
      try {
        page = await doc.getPage(index + 1);
        final pw = page.width;
        final ph = page.height;
        if (pw <= 0 || ph <= 0) return null;

        final scale = min(maxPixelsW / pw, maxPixelsH / ph);
        final rw = (pw * scale).round().clamp(1, 8192);
        final rh = (ph * scale).round().clamp(1, 8192);

        final img = await page.render(
          width: rw.toDouble(),
          height: rh.toDouble(),
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#ffffff',
          quality: 90,
        );
        if (img == null) return null;
        _bitmapCache[key] = img.bytes;
        return img.bytes;
      } finally {
        await page?.close();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    final doc = _document;
    _document = null;
    if (doc != null) {
      unawaited(doc.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenH = MediaQuery.sizeOf(context).height;
    final viewerHeight = screenH * 0.78;
    final fabClearance = screenH * 0.12;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.55);
    const pageAnim = Duration(milliseconds: 280);
    const pageCurve = Curves.easeOutCubic;

    final err = _openError;
    if (err != null) {
      return ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              l10n.couldNotDisplayPdf('$err'),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_document == null || _pageCount == 0) {
      return ColoredBox(
        color: bg,
        child: SizedBox(
          height: viewerHeight + fabClearance,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ColoredBox(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe_rounded, size: 18, color: muted),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.pinchToZoomPdf,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: l10n.previousPage,
                onPressed: _currentPage > 1
                    ? () => _pageController.animateToPage(
                        _currentPage - 2,
                        duration: pageAnim,
                        curve: pageCurve,
                      )
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.pdfPageIndicator(_currentPage, _pageCount),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (_pageCount > 1)
                    _PartitionPdfPageDots(
                      currentPage: _currentPage,
                      pageCount: _pageCount,
                    ),
                ],
              ),
              IconButton(
                tooltip: l10n.nextPage,
                onPressed: _currentPage < _pageCount
                    ? () => _pageController.animateToPage(
                        _currentPage,
                        duration: pageAnim,
                        curve: pageCurve,
                      )
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          SizedBox(
            height: viewerHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(
                      parent: PageScrollPhysics(),
                    ),
                    itemCount: _pageCount,
                    onPageChanged: (i) => setState(() => _currentPage = i + 1),
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final dpr = MediaQuery.devicePixelRatioOf(context);
                          final mw = (constraints.maxWidth * dpr).round().clamp(
                            1,
                            8192,
                          );
                          final mh = (constraints.maxHeight * dpr)
                              .round()
                              .clamp(1, 8192);
                          return FutureBuilder<Uint8List?>(
                            future: _bitmapForPage(index, mw, mh),
                            builder: (context, snap) {
                              if (snap.connectionState !=
                                  ConnectionState.done) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snap.hasError ||
                                  snap.data == null ||
                                  snap.data!.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text(
                                      l10n.couldNotDisplayPdf('${snap.error}'),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }
                              return _PartitionPdfZoomPage(bytes: snap.data!);
                            },
                          );
                        },
                      );
                    },
                  ),
                  IgnorePointer(
                    child: _PartitionPdfScrollCueOverlay(
                      currentPage: _currentPage,
                      pageCount: _pageCount,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: fabClearance),
        ],
      ),
    );
  }
}

/// One page bitmap with pinch-zoom; pan is enabled only when zoomed so
/// horizontal drags go to [PageView].
class _PartitionPdfZoomPage extends StatefulWidget {
  const _PartitionPdfZoomPage({required this.bytes});

  final Uint8List bytes;

  @override
  State<_PartitionPdfZoomPage> createState() => _PartitionPdfZoomPageState();
}

class _PartitionPdfZoomPageState extends State<_PartitionPdfZoomPage> {
  final TransformationController _transform = TransformationController();
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transform.value.getMaxScaleOnAxis();
    final z = scale > 1.03;
    if (z != _zoomed && mounted) setState(() => _zoomed = z);
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    super.dispose();
  }

  void _resetZoom() => _transform.value = Matrix4.identity();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onDoubleTap: _resetZoom,
        child: InteractiveViewer(
          transformationController: _transform,
          panEnabled: _zoomed,
          scaleEnabled: true,
          minScale: 1,
          maxScale: 4,
          boundaryMargin: const EdgeInsets.all(120),
          clipBehavior: Clip.hardEdge,
          child: Center(
            child: Image.memory(
              widget.bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped dots under the numeric page label (carousel indicator).
class _PartitionPdfPageDots extends StatelessWidget {
  const _PartitionPdfPageDots({
    required this.currentPage,
    required this.pageCount,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(pageCount, (i) {
          final active = i + 1 == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: active
                    ? scheme.primary
                    : scheme.outline.withValues(alpha: 0.4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Subtle side chevrons when more pages exist in that direction (scroll cue).
class _PartitionPdfScrollCueOverlay extends StatelessWidget {
  const _PartitionPdfScrollCueOverlay({
    required this.currentPage,
    required this.pageCount,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final cueColor = scheme.primary.withValues(alpha: 0.32);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (currentPage > 1)
          Positioned(
            left: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 40,
                color: cueColor,
              ),
            ),
          ),
        if (currentPage < pageCount)
          Positioned(
            right: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.chevron_right_rounded,
                size: 40,
                color: cueColor,
              ),
            ),
          ),
      ],
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String lyricsLabel;
  final String sheetMusicLabel;
  final int selectedIndex;
  final Function(int) onTabSelected;

  _TabHeaderDelegate({
    required this.lyricsLabel,
    required this.sheetMusicLabel,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        height: maxExtent,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selectedIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.2),
                        width: selectedIndex == 0 ? 3 : 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      lyricsLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selectedIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(1),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selectedIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.2),
                        width: selectedIndex == 1 ? 3 : 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      sheetMusicLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selectedIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyMedium!.color
                                  ?.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
