import 'dart:async';
import 'dart:io';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/harmonyforge/harmonyforge_media_service.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/language_toggle.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/projection_view.dart';
import 'package:fgm_lyrics_app/app/settings/typography_settings_provider.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  /// Hymn content currently shown (swaps when the language toggle succeeds).
  late Lyric _displayedLyric;

  /// Non-null once audio is available locally (downloaded or cached).
  String? _localAudioPath;

  /// Non-null once the partition PDF has been downloaded locally.
  String? _localPartitionPath;

  bool _audioDownloading = false;
  bool _partitionDownloading = false;

  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  bool _isSeeking = false;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  String _getAssetAudioSource() => 'songs/${_displayedLyric.id}.mp3';

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
    super.initState();
    _displayedLyric = widget.lyric;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _positionSub = _audioPlayer.onPositionChanged.listen((position) {
      if (!_isSeeking && mounted) {
        setState(() => _audioPosition = position);
      }
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _audioDuration = duration);
    });
    _playerStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      if (state == PlayerState.playing) {
        if (!_animationController.isCompleted) {
          _animationController.forward();
        }
      } else if (state == PlayerState.paused ||
          state == PlayerState.stopped ||
          state == PlayerState.completed) {
        if (_animationController.isCompleted) {
          _animationController.reverse();
        }
      }
      if (state == PlayerState.completed) {
        setState(() => _audioPosition = Duration.zero);
      }
    });
  }

  Future<void> _checkAudioAndPartitionAvailability() async {
    final media = ref.read(harmonyForgeMediaServiceProvider);
    final fromAssets = await _assetAudioExists();
    final localAudio = await media.getLocalAudioPath(
      _displayedLyric.songId,
      _displayedLyric.contentLanguage,
    );
    final localPartition = await media.getLocalPartitionPath(
      _displayedLyric.songId,
      _displayedLyric.contentLanguage,
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
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _seekTo(Duration position) async {
    final maxMs = _audioDuration.inMilliseconds;
    if (maxMs <= 0) return;
    final clamped = Duration(
      milliseconds: position.inMilliseconds.clamp(0, maxMs),
    );
    await _audioPlayer.seek(clamped);
    if (mounted) setState(() => _audioPosition = clamped);
  }

  Future<void> _seekRelative(Duration offset) async {
    await _seekTo(_audioPosition + offset);
  }

  /// Favorite key: id can be int (e.g. 1) or string (e.g. "160A").
  String get _favoriteIdKey => _displayedLyric.id.toString();

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Lyric? _findCounterpart(List<Lyric>? list, {required bool wantEnglish}) {
    if (list == null) return null;
    final id = _displayedLyric.id.toString();
    for (final lyric in list) {
      if (lyric.id.toString() != id) continue;
      if (wantEnglish ? lyric.availableInEn : lyric.availableInFr) {
        return lyric;
      }
    }
    return null;
  }

  Future<void> _applyDisplayedLyric(Lyric next) async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
    if (_animationController.isCompleted) {
      _animationController.reset();
    }
    if (!mounted) return;
    setState(() {
      _displayedLyric = next;
      _audioFileAvailable = false;
      _localAudioPath = null;
      _localPartitionPath = null;
      _audioPosition = Duration.zero;
      _audioDuration = Duration.zero;
      _audioDownloading = false;
      _partitionDownloading = false;
    });
    await _checkAudioAndPartitionAvailability();
  }

  Future<void> _onSelectLanguage({required bool wantEnglish}) async {
    final currentlyEnglish = _displayedLyric.contentLanguage == 'en';
    if (wantEnglish == currentlyEnglish) return;

    final l10n = AppLocalizations.of(context)!;
    final otherList = wantEnglish
        ? ref.read(englishHymnProvider).value
        : ref.read(frenchHymnProvider).value;
    final counterpart = _findCounterpart(otherList, wantEnglish: wantEnglish);

    if (counterpart == null) {
      _showSnackBar(l10n.hymnNoTranslation);
      return;
    }

    await ref
        .read(deviceLocaleProvider.notifier)
        .setLocale(wantEnglish ? LanguageEnum.en : LanguageEnum.fr);
    await _applyDisplayedLyric(counterpart);
  }

  /// Plays from local if cached, downloads then plays if only a remote URL
  /// is available, or plays from a bundled asset.
  Future<void> _handleAudioPlayTap() async {
    if (_localAudioPath != null) {
      await _playOrPauseAudio();
    } else if (_displayedLyric.audioUrl.isNotEmpty) {
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
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (_audioPlayer.state == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    try {
      final source = _localAudioPath != null
          ? DeviceFileSource(_localAudioPath!) as Source
          : AssetSource(_getAssetAudioSource());
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (_localAudioPath != null) {
        await _deleteCorruptAudio();
        if (_displayedLyric.audioUrl.isNotEmpty) {
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
            _displayedLyric.songId,
            _displayedLyric.audioUrl,
            _displayedLyric.contentLanguage,
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
            _displayedLyric.songId,
            _displayedLyric.partitionUrl,
            _displayedLyric.contentLanguage,
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
          .toggleFavorite(_displayedLyric.id);
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

    ref.listen<String>(deviceLocaleProvider, (previous, next) {
      final wantEnglish = next == LanguageEnum.en.name;
      final currentlyEnglish = _displayedLyric.contentLanguage == 'en';
      if (wantEnglish == currentlyEnglish) return;
      final otherList = wantEnglish
          ? ref.read(englishHymnProvider).value
          : ref.read(frenchHymnProvider).value;
      final counterpart = _findCounterpart(otherList, wantEnglish: wantEnglish);
      if (counterpart != null) {
        _applyDisplayedLyric(counterpart);
      }
    });

    final audioBar = _buildAudioPlayerBar(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                stretch: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                scrolledUnderElevation: 0,
                // Compact header: full hymn info when expanded, reduced title when collapsed.
                expandedHeight: 148,
                actions: [
                  IconButton(
                    icon: ref.watch(themeProvider) == ThemeMode.light
                        ? const Icon(LucideIcons.moon)
                        : const Icon(LucideIcons.sun),
                    onPressed: () =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                  IconButton(
                    onPressed: () {
                      _sharePlus.share(
                        ShareParams(
                          text: hymnText,
                          subject:
                              '${_displayedLyric.songTitle.capitalize}'
                              '${l10n.shareSubjectSuffix}',
                        ),
                      );
                    },
                    icon: const Icon(LucideIcons.share),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _toggleFavorite();
                    },
                    icon: Icon(
                      LucideIcons.heart,
                      color: (isFavorite.value ?? false)
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final topPad = MediaQuery.paddingOf(context).top;
                    final minHeight = topPad + kToolbarHeight;
                    final maxHeight = topPad + 148;
                    final range = (maxHeight - minHeight).clamp(
                      1.0,
                      double.infinity,
                    );
                    final t = ((constraints.maxHeight - minHeight) / range)
                        .clamp(0.0, 1.0);
                    final collapsedT = 1.0 - t;
                    final scheme = Theme.of(context).colorScheme;
                    final bg = Theme.of(context).scaffoldBackgroundColor;
                    final numberPrefix =
                        _displayedLyric.displayNumber.isNotEmpty
                        ? '${_displayedLyric.displayNumber}. '
                        : '';
                    final titleText =
                        '$numberPrefix${_displayedLyric.songTitle.capitalize}';

                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Soft logo watermark — fades as the header collapses.
                        Opacity(
                          opacity: 0.12 * t,
                          child: Image.asset(
                            'assets/logo2.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                bg.withValues(alpha: 0.55 + 0.35 * collapsedT),
                                bg,
                              ],
                            ),
                          ),
                        ),
                        // Expanded content: large title + author + metadata.
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 10,
                          child: IgnorePointer(
                            ignoring: t < 0.15,
                            child: Opacity(
                              opacity: Curves.easeOut.transform(t),
                              child: Transform.translate(
                                offset: Offset(0, 12 * collapsedT),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      titleText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.fraunces(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    if (_displayedLyric.author.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _displayedLyric.author,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurface
                                                  .withValues(alpha: 0.65),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    _buildMetadataChips(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Collapsed title — pinned in the toolbar area.
                        Positioned(
                          left: 56,
                          right: 132,
                          top: topPad,
                          height: kToolbarHeight,
                          child: IgnorePointer(
                            ignoring: collapsedT < 0.4,
                            child: Opacity(
                              opacity: Curves.easeIn.transform(
                                ((collapsedT - 0.35) / 0.65).clamp(0.0, 1.0),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  titleText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fraunces(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Persistent Tab Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabHeaderDelegate(
                  lyricsLabel: l10n.lyricsTab,
                  sheetMusicLabel: l10n.sheetMusicTab,
                  projectionLabel: l10n.projectionTab,
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
                    const SizedBox(height: 12),
                    LanguageToggle(
                      isEnglish: _displayedLyric.contentLanguage == 'en',
                      frenchLabel: l10n.languageFrench,
                      englishLabel: l10n.languageEnglish,
                      onSelectFrench: () =>
                          _onSelectLanguage(wantEnglish: false),
                      onSelectEnglish: () =>
                          _onSelectLanguage(wantEnglish: true),
                    ),
                    const SizedBox(height: 8),
                    _buildTabContentSwitcher(),
                  ]),
                ),
              ),
              if (audioBar != null)
                SliverToBoxAdapter(child: SizedBox(height: 110 + bottomInset)),
            ],
          ),
          if (audioBar != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 10 + bottomInset,
              child: audioBar,
            ),
        ],
      ),
    );
  }

  /// Floating music player, shown only on the lyrics tab when audio is
  /// available locally or remotely.
  Widget? _buildAudioPlayerBar(BuildContext context) {
    if (_selectedTabIndex != 0) return null;

    final hasLocal = _localAudioPath != null || _audioFileAvailable;
    final hasRemote = _displayedLyric.audioUrl.isNotEmpty;
    if (!hasLocal && !hasRemote) return null;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isReady = hasLocal && !_audioDownloading;
    final isDownloading = _audioDownloading;
    final canSeek = isReady && _audioDuration.inMilliseconds > 0;
    final progress = canSeek
        ? (_audioPosition.inMilliseconds / _audioDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Material(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.28 : 0.12),
        ),
      ),
      color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    _formatDuration(_audioPosition),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: canSeek
                          ? (value) {
                              setState(() {
                                _isSeeking = true;
                                _audioPosition = Duration(
                                  milliseconds:
                                      (_audioDuration.inMilliseconds * value)
                                          .round(),
                                );
                              });
                            }
                          : null,
                      onChangeEnd: canSeek
                          ? (value) async {
                              setState(() => _isSeeking = false);
                              await _seekTo(
                                Duration(
                                  milliseconds:
                                      (_audioDuration.inMilliseconds * value)
                                          .round(),
                                ),
                              );
                            }
                          : null,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primary.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    _formatDuration(_audioDuration),
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '-10s',
                  onPressed: canSeek
                      ? () => _seekRelative(const Duration(seconds: -10))
                      : null,
                  icon: const Icon(LucideIcons.rotateCcw, size: 20),
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    minimumSize: const Size(44, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: isDownloading
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primary,
                    foregroundColor: isDownloading
                        ? colorScheme.primary
                        : colorScheme.onPrimary,
                  ),
                  onPressed: isDownloading ? null : _handleAudioPlayTap,
                  child: isDownloading
                      ? const AppProgressIndicator(size: 20, strokeWidth: 2.4)
                      : isReady
                      ? Icon(
                          _audioPlayer.state == PlayerState.playing
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          size: 22,
                        )
                      : const Icon(LucideIcons.download, size: 22),
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '+10s',
                  onPressed: canSeek
                      ? () => _seekRelative(const Duration(seconds: 10))
                      : null,
                  icon: const Icon(LucideIcons.rotateCw, size: 20),
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataChips() {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final year = _displayedLyric.displayYear.isNotEmpty
        ? _displayedLyric.displayYear
        : l10n.notAvailable;
    final key = _displayedLyric.key.isNotEmpty
        ? _displayedLyric.key
        : l10n.notAvailable;

    Widget chip(String label, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label · ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [chip(l10n.composedLabel, year), chip(l10n.keyLabel, key)],
    );
  }

  Widget _buildTabContentSwitcher() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: switch (_selectedTabIndex) {
        0 => _buildLyricsContent(),
        1 => _buildSheetMusicContent(),
        _ => ProjectionTabContent(
          key: const ValueKey('projection_tab'),
          lyric: _displayedLyric,
        ),
      },
    );
  }

  Widget _buildLyricsContent() {
    final chorusPlain = _displayedLyric.chorus.stripHtmlTags;
    final verses = _displayedLyric.enLyrics;

    return Padding(
      key: const ValueKey('lyrics'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (verses.isNotEmpty) LyricItem(index: 1, verse: verses.first),

          if (chorusPlain.isNotEmpty) ...[
            const SizedBox(height: 28),
            _ChorusBlock(chorus: _displayedLyric.chorus),
          ],

          if (verses.length > 1)
            ...verses.skip(1).toList().asMap().entries.map((entry) {
              final verseIndex = entry.key + 2;
              return Padding(
                padding: const EdgeInsets.only(top: 28),
                child: LyricItem(verse: entry.value, index: verseIndex),
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
    final hasRemote = _displayedLyric.partitionUrl.isNotEmpty;

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
    final leadingIcon = hasLocal ? LucideIcons.fileText : LucideIcons.music;
    final leadingColor = hasLocal
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;

    return Padding(
      key: const ValueKey('sheet_music'),
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, size: 56, color: leadingColor),
          const SizedBox(height: 14),
          Text(
            l10n.sheetMusicHeading,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            const SizedBox(height: 20),
            if (_partitionDownloading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: AppProgressIndicator(),
              )
            else
              FilledButton.icon(
                onPressed: hasLocal
                    ? () => _openPartitionExternally(path)
                    : _downloadThenOpenPartition,
                icon: Icon(
                  hasLocal ? LucideIcons.externalLink : LucideIcons.download,
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
    final numberPrefix = _displayedLyric.displayNumber.isNotEmpty
        ? "${_displayedLyric.displayNumber}.  "
        : '';
    final firstVerse = _displayedLyric.enLyrics.first.stripHtmlTags;
    final chorus = _displayedLyric.chorus.stripHtmlTags;
    final chorusLabel = _displayedLyric.chorus.isNotEmpty
        ? (ref.watch(deviceLocaleProvider) == LanguageEnum.en.name
              ? l10n.shareChorusPrefix
              : l10n.shareRefrainPrefix)
        : '';
    final remainingVerses = _displayedLyric.enLyrics.length > 1
        ? _displayedLyric.enLyrics
              .sublist(1, _displayedLyric.enLyrics.length - 1)
              .map((v) => '${v.stripHtmlTags.trim()}\n\n')
              .join(' ')
        : '';
    return '*$numberPrefix${_displayedLyric.songTitle.stripHtmlTags}*\n\n'
        '$firstVerse\n\n\n'
        '${chorus.isNotEmpty ? '$chorusLabel$chorus\n\n\n' : ''}'
        '$remainingVerses';
  }
}

class LyricItem extends ConsumerWidget {
  const LyricItem({super.key, required this.verse, required this.index});

  final String verse;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fontSize = ref.watch(fontSizeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LyricSectionLabel(label: l10n.verseLabel(index)),
        const SizedBox(height: 10),
        _FrauncesLyricLines(
          lines: verse.lyricLines,
          fontSize: fontSize,
          color: scheme.onSurface,
        ),
      ],
    );
  }
}

class _ChorusBlock extends ConsumerWidget {
  const _ChorusBlock({required this.chorus});

  final String chorus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fontSize = ref.watch(fontSizeProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LyricSectionLabel(label: l10n.chorusSectionLabel),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: isDark ? 0.16 : 0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border(left: BorderSide(color: scheme.primary, width: 4)),
          ),
          child: _FrauncesLyricLines(
            lines: chorus.lyricLines,
            fontSize: fontSize,
            color: scheme.onSurface,
            italic: true,
          ),
        ),
      ],
    );
  }
}

class _LyricSectionLabel extends StatelessWidget {
  const _LyricSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: scheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        height: 1.2,
      ),
    );
  }
}

class _FrauncesLyricLines extends StatelessWidget {
  const _FrauncesLyricLines({
    required this.lines,
    required this.fontSize,
    required this.color,
    this.italic = false,
  });

  final List<String> lines;
  final double fontSize;
  final Color color;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    return Text(
      lines.join('\n'),
      textAlign: TextAlign.start,
      style: GoogleFonts.fraunces(
        fontSize: fontSize,
        height: 1.55,
        color: color,
        fontWeight: FontWeight.w400,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
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
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
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
                        LucideIcons.imageOff,
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
          child: const Center(child: AppProgressIndicator()),
        ),
      );
    }

    return ColoredBox(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.moveHorizontal, size: 16, color: muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.pinchToZoomPdf,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: muted, height: 1.2),
                  ),
                ),
              ],
            ),
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
                                  child: AppProgressIndicator(),
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
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.previousPage,
                  onPressed: _currentPage > 1
                      ? () => _pageController.animateToPage(
                          _currentPage - 2,
                          duration: pageAnim,
                          curve: pageCurve,
                        )
                      : null,
                  icon: const Icon(LucideIcons.chevronLeft),
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
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n.nextPage,
                  onPressed: _currentPage < _pageCount
                      ? () => _pageController.animateToPage(
                          _currentPage,
                          duration: pageAnim,
                          curve: pageCurve,
                        )
                      : null,
                  icon: const Icon(LucideIcons.chevronRight),
                ),
              ],
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
              child: Icon(LucideIcons.chevronLeft, size: 40, color: cueColor),
            ),
          ),
        if (currentPage < pageCount)
          Positioned(
            right: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(LucideIcons.chevronRight, size: 40, color: cueColor),
            ),
          ),
      ],
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String lyricsLabel;
  final String sheetMusicLabel;
  final String projectionLabel;
  final int selectedIndex;
  final Function(int) onTabSelected;

  _TabHeaderDelegate({
    required this.lyricsLabel,
    required this.sheetMusicLabel,
    required this.projectionLabel,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  Widget _buildTab({
    required BuildContext context,
    required String label,
    required int index,
  }) {
    final selected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor.withValues(alpha: 0.2),
                width: selected ? 3 : 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

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
            _buildTab(context: context, label: lyricsLabel, index: 0),
            _buildTab(context: context, label: sheetMusicLabel, index: 1),
            _buildTab(context: context, label: projectionLabel, index: 2),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
