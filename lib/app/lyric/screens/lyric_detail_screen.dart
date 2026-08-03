import 'dart:async';
import 'dart:io';
import 'dart:math' show min;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/harmonyforge/harmonyforge_media_service.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/widgets/projection_view.dart';
import 'package:fgm_lyrics_app/app/settings/typography_settings_provider.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/language_toggle.dart';
import 'package:fgm_lyrics_app/core/theme/app_fonts.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:fgm_lyrics_app/core/utils/image_decode.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:open_file/open_file.dart';
import 'package:pdfx/pdfx.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  /// 1 = tab chrome visible; 0 = chrome hidden while scrolling.
  late final AnimationController _chromeController;
  late final Animation<double> _chromeExpand;
  late final PageController _tabPageController;
  final _audioPlayer = AudioPlayer();
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

  final ValueNotifier<Duration> _audioPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> _audioDuration = ValueNotifier(Duration.zero);
  bool _isSeeking = false;

  /// Collapses tab/language chrome unless the content is scrolled to the top.
  bool _uiCompact = false;

  static const _kTabHeaderExtent = 52.0;
  static const _kChromeAnimDuration = Duration(milliseconds: 340);

  /// Show chrome only when scroll offset is at (or extremely near) the top.
  static const _kChromeTopThreshold = 8.0;

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
    _tabPageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _chromeController = AnimationController(
      vsync: this,
      duration: _kChromeAnimDuration,
      value: 1,
    );
    _chromeExpand = CurvedAnimation(
      parent: _chromeController,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _positionSub = _audioPlayer.onPositionChanged.listen((position) {
      if (!_isSeeking && mounted) {
        _audioPosition.value = position;
      }
    });
    _durationSub = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) _audioDuration.value = duration;
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
        _audioPosition.value = Duration.zero;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkAudioAndPartitionAvailability();
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
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _positionSub = null;
    _durationSub = null;
    _playerStateSub = null;
    _audioPosition.dispose();
    _audioDuration.dispose();
    _tabPageController.dispose();
    _chromeController.dispose();
    _animationController.stop();
    _animationController.dispose();
    // Stop playback before releasing the native player.
    unawaited(_audioPlayer.stop().catchError((_) {}));
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _setUiCompact(false);
    if (!_tabPageController.hasClients) return;
    _tabPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onTabPageChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _setUiCompact(false);
  }

  void _setUiCompact(bool compact) {
    if (_uiCompact == compact) return;
    _uiCompact = compact;
    if (compact) {
      _chromeController.reverse();
    } else {
      _chromeController.forward();
    }
  }

  bool _onContentScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification) {
      return false;
    }
    if (notification.metrics.axis != Axis.vertical) return false;
    final atTop = notification.metrics.pixels <= _kChromeTopThreshold;
    _setUiCompact(!atTop);
    return false;
  }

  Future<void> _seekTo(Duration position) async {
    final maxMs = _audioDuration.value.inMilliseconds;
    if (maxMs <= 0) return;
    final clamped = Duration(
      milliseconds: position.inMilliseconds.clamp(0, maxMs),
    );
    await _audioPlayer.seek(clamped);
    if (mounted) _audioPosition.value = clamped;
  }

  Future<void> _seekRelative(Duration offset) async {
    await _seekTo(_audioPosition.value + offset);
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
      _audioDownloading = false;
      _partitionDownloading = false;
    });
    _audioPosition.value = Duration.zero;
    _audioDuration.value = Duration.zero;
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

  /// Opens a locally cached partition in an external app (unsupported formats
  /// only — PDF and images use the in-app viewers).
  Future<void> _openPartitionExternally(String path) async {
    if (_isImagePartitionPath(path) || _isPdfPartitionPath(path)) return;
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

    final hasLocalAudio = _localAudioPath != null || _audioFileAvailable;
    final hasRemoteAudio = _displayedLyric.audioUrl.isNotEmpty;
    final showAudioBar =
        _selectedTabIndex == 0 && (hasLocalAudio || hasRemoteAudio);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Mini player is the default height (expanded chrome no longer grows it).
    final audioBarBottomPadding = showAudioBar ? 92 + bottomInset : 32.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onContentScroll,
        child: AnimatedBuilder(
          animation: _chromeExpand,
          child: _DetailTabBody(
            pageController: _tabPageController,
            onPageChanged: _onTabPageChanged,
            lyric: _displayedLyric,
            localPartitionPath: _localPartitionPath,
            partitionDownloading: _partitionDownloading,
            onOpenPartitionExternally: _openPartitionExternally,
            onDownloadPartition: _downloadThenOpenPartition,
            bottomContentPadding: audioBarBottomPadding,
          ),
          builder: (context, tabBody) {
            final chrome = _chromeExpand.value;

            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      toolbarHeight: 88,
                      titleSpacing: 0,
                      leadingWidth: 64,
                      leading: BackButton(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.72),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      actions: [
                        IconButton(
                          tooltip: (isFavorite.value ?? false)
                              ? l10n.removeFromFavorites
                              : l10n.addToFavorites,
                          onPressed: () async {
                            await _toggleFavorite();
                          },
                          icon: Icon(
                            (isFavorite.value ?? false)
                                ? Icons.favorite_rounded
                                : LucideIcons.heart,
                            size: 22,
                            color: (isFavorite.value ?? false)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.32),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            IgnorePointer(
                              child: Image.asset(
                                'assets/logo2.png',
                                fit: BoxFit.contain,
                                alignment: Alignment.center,
                                opacity: const AlwaysStoppedAnimation(0.08),
                                cacheWidth: imageCachePx(context, 180),
                                cacheHeight: imageCachePx(context, 180),
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                            SafeArea(
                              bottom: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 72,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.detailBrandTitle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                          height: 1.15,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.detailBrandSubtitle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: AppFonts.fraunces,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          height: 1.15,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
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

                    // Persistent Tab Header (softly hides while scrolling down).
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabHeaderDelegate(
                        visibility: chrome,
                        // Snap tiny animated extents to 0 — fractional heights
                        // with an empty child break SliverGeometry (layoutExtent
                        // > paintExtent).
                        extent: chrome < 0.02
                            ? 0.0
                            : _kTabHeaderExtent * chrome,
                        lyricsLabel: l10n.lyricsTab,
                        sheetMusicLabel: l10n.sheetMusicTab,
                        projectionLabel: l10n.projectionTab,
                        songHistoryLabel: l10n.songHistoryTab,
                        selectedIndex: _selectedTabIndex,
                        onTabSelected: _onTabSelected,
                        isEnglish: _displayedLyric.contentLanguage == 'en',
                        frenchLabel: l10n.languageFrench,
                        englishLabel: l10n.languageEnglish,
                        onSelectFrench: () =>
                            _onSelectLanguage(wantEnglish: false),
                        onSelectEnglish: () =>
                            _onSelectLanguage(wantEnglish: true),
                      ),
                    ),
                    SliverFillRemaining(hasScrollBody: true, child: tabBody!),
                  ],
                ),
                if (showAudioBar)
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 10 + bottomInset,
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _audioPosition,
                        _audioDuration,
                      ]),
                      builder: (context, _) {
                        return _FloatingAudioPlayerBar(
                          expandProgress: chrome,
                          title: _displayedLyric.songTitle.capitalize,
                          position: _audioPosition.value,
                          duration: _audioDuration.value,
                          isDownloading: _audioDownloading,
                          isReady: hasLocalAudio && !_audioDownloading,
                          playerState: _audioPlayer.state,
                          onSeekPreview: (position) {
                            _isSeeking = true;
                            _audioPosition.value = position;
                          },
                          onSeekEnd: (position) async {
                            _isSeeking = false;
                            await _seekTo(position);
                          },
                          onSeekRelative: _seekRelative,
                          onPlayTap: _handleAudioPlayTap,
                          onExpand: () => _setUiCompact(false),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Used by the commented full expanded player layout below.
// ignore: unused_element
String _formatPlayerDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

bool _isImagePartitionPath(String path) {
  final ext = path.split('.').last.toLowerCase();
  return const {'png', 'jpg', 'jpeg', 'webp'}.contains(ext);
}

bool _isPdfPartitionPath(String path) =>
    path.split('.').last.toLowerCase() == 'pdf';

/// Floating music player for the lyrics tab.
///
/// Default UI is the compact (minified) player. The previous full expanded
/// layout is kept below, commented out, for easy restoration.
class _FloatingAudioPlayerBar extends StatelessWidget {
  const _FloatingAudioPlayerBar({
    required this.expandProgress,
    required this.title,
    required this.position,
    required this.duration,
    required this.isDownloading,
    required this.isReady,
    required this.playerState,
    required this.onSeekPreview,
    required this.onSeekEnd,
    required this.onSeekRelative,
    required this.onPlayTap,
    required this.onExpand,
  });

  /// Kept for chrome animation coupling; mini player is always shown.
  final double expandProgress;
  final String title;
  final Duration position;
  final Duration duration;
  final bool isDownloading;
  final bool isReady;
  final PlayerState playerState;
  final ValueChanged<Duration> onSeekPreview;
  final ValueChanged<Duration> onSeekEnd;
  final ValueChanged<Duration> onSeekRelative;
  final VoidCallback onPlayTap;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final canSeek = isReady && duration.inMilliseconds > 0;
    final progress = canSeek
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final l10n = AppLocalizations.of(context)!;
    final isPlaying = playerState == PlayerState.playing;
    final muted = scheme.onSurface.withValues(alpha: isDark ? 0.55 : 0.45);
    final statusLabel = isDownloading
        ? l10n.audioDownloading
        : isReady
        ? (isPlaying ? l10n.audioNowPlaying : l10n.audioReadyToPlay)
        : l10n.audioTapToDownload;

    // Kept for the commented expanded layout (expandProgress).
    // ignore: unused_local_variable
    final _ = expandProgress;
    const radius = 26.0;

    return Material(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: scheme.primary.withValues(alpha: isDark ? 0.32 : 0.14),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2C231F), Color(0xFF181412)]
                : const [Color(0xFFFFFCF9), Color(0xFFF8EDE6)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
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
                      scheme.primary.withValues(alpha: 0.15),
                      scheme.primary,
                      scheme.primary.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
            _MinimizedAudioPlayerContent(
              title: title,
              duration: duration,
              progress: progress,
              canSeek: canSeek,
              isDownloading: isDownloading,
              isReady: isReady,
              isPlaying: isPlaying,
              statusLabel: statusLabel,
              muted: muted,
              onSeekPreview: onSeekPreview,
              onSeekEnd: onSeekEnd,
              onSeekRelative: onSeekRelative,
              onPlayTap: onPlayTap,
              onExpand: onExpand,
            ),
            /*
            // ── Full expanded player (initial version) ──────────────────────
            // Restore by swapping this block with the mini content above and
            // driving visibility with [expandProgress] (t).
            ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: t,
                child: Opacity(
                  opacity: t,
                  child: IgnorePointer(
                    ignoring: t < 0.9,
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
                                  scheme.primary.withValues(alpha: 0.15),
                                  scheme.primary,
                                  scheme.primary.withValues(alpha: 0.15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          scheme.primary.withValues(
                                            alpha: 0.16,
                                          ),
                                          scheme.primary.withValues(
                                            alpha: 0.06,
                                          ),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: scheme.primary.withValues(
                                          alpha: 0.18,
                                        ),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: Image.asset(
                                        'assets/logo2.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.fraunces(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w700,
                                            height: 1.15,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (isPlaying) ...[
                                              _PlayingDots(
                                                color: scheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                            ],
                                            Flexible(
                                              child: Text(
                                                statusLabel,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.15,
                                                  color: isPlaying
                                                      ? scheme.primary
                                                            .withValues(
                                                              alpha: isDark
                                                                  ? 0.95
                                                                  : 0.85,
                                                            )
                                                      : muted,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _PlayerTransportButton(
                                    onPressed: isDownloading ? null : onPlayTap,
                                    primary: scheme.primary,
                                    onPrimary: scheme.onPrimary,
                                    child: isDownloading
                                        ? AppProgressIndicator(
                                            size: 20,
                                            strokeWidth: 2.4,
                                            color: scheme.onPrimary,
                                            trackColor: scheme.onPrimary
                                                .withValues(alpha: 0.25),
                                          )
                                        : Icon(
                                            isReady
                                                ? (isPlaying
                                                      ? LucideIcons.pause
                                                      : LucideIcons.play)
                                                : LucideIcons.download,
                                            size: 22,
                                            color: scheme.onPrimary,
                                          ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4,
                                  trackShape:
                                      const RoundedRectSliderTrackShape(),
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7.5,
                                    elevation: 1.5,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 16,
                                  ),
                                  activeTrackColor: scheme.primary,
                                  inactiveTrackColor: scheme.primary.withValues(
                                    alpha: 0.14,
                                  ),
                                  thumbColor: scheme.primary,
                                  overlayColor: scheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                child: Slider(
                                  value: progress,
                                  onChanged: canSeek
                                      ? (value) {
                                          onSeekPreview(
                                            Duration(
                                              milliseconds:
                                                  (duration.inMilliseconds *
                                                          value)
                                                      .round(),
                                            ),
                                          );
                                        }
                                      : null,
                                  onChangeEnd: canSeek
                                      ? (value) {
                                          onSeekEnd(
                                            Duration(
                                              milliseconds:
                                                  (duration.inMilliseconds *
                                                          value)
                                                      .round(),
                                            ),
                                          );
                                        }
                                      : null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        _formatPlayerDuration(position),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _SeekChip(
                                            icon: LucideIcons.rotateCcw,
                                            enabled: canSeek,
                                            onTap: () => onSeekRelative(
                                              const Duration(seconds: -5),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          _SeekChip(
                                            icon: LucideIcons.rotateCw,
                                            enabled: canSeek,
                                            onTap: () => onSeekRelative(
                                              const Duration(seconds: 5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        _formatPlayerDuration(duration),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          color: muted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}

class _MinimizedAudioPlayerContent extends StatelessWidget {
  const _MinimizedAudioPlayerContent({
    required this.title,
    required this.duration,
    required this.progress,
    required this.canSeek,
    required this.isDownloading,
    required this.isReady,
    required this.isPlaying,
    required this.statusLabel,
    required this.muted,
    required this.onSeekPreview,
    required this.onSeekEnd,
    required this.onSeekRelative,
    required this.onPlayTap,
    required this.onExpand,
  });

  final String title;
  final Duration duration;
  final double progress;
  final bool canSeek;
  final bool isDownloading;
  final bool isReady;
  final bool isPlaying;
  final String statusLabel;
  final Color muted;
  final ValueChanged<Duration> onSeekPreview;
  final ValueChanged<Duration> onSeekEnd;
  final ValueChanged<Duration> onSeekRelative;
  final VoidCallback onPlayTap;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onExpand,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.fraunces(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (isPlaying) ...[
                                _PlayingDots(color: scheme.primary),
                                const SizedBox(width: 6),
                              ],
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isPlaying
                                        ? scheme.primary.withValues(
                                            alpha: isDark ? 0.95 : 0.85,
                                          )
                                        : muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SeekChip(
                icon: LucideIcons.rotateCcw,
                enabled: canSeek,
                onTap: () => onSeekRelative(const Duration(seconds: -5)),
              ),
              const SizedBox(width: 6),
              _PlayerTransportButton(
                onPressed: isDownloading ? null : onPlayTap,
                primary: scheme.primary,
                onPrimary: scheme.onPrimary,
                compact: true,
                child: isDownloading
                    ? AppProgressIndicator(
                        size: 16,
                        strokeWidth: 2.2,
                        color: scheme.onPrimary,
                        trackColor: scheme.onPrimary.withValues(alpha: 0.25),
                      )
                    : Icon(
                        isReady
                            ? (isPlaying ? LucideIcons.pause : LucideIcons.play)
                            : LucideIcons.download,
                        size: 18,
                        color: scheme.onPrimary,
                      ),
              ),
              const SizedBox(width: 6),
              _SeekChip(
                icon: LucideIcons.rotateCw,
                enabled: canSeek,
                onTap: () => onSeekRelative(const Duration(seconds: 5)),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              trackShape: const RoundedRectSliderTrackShape(),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 3.5,
                elevation: 0.5,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.primary.withValues(alpha: 0.14),
              thumbColor: scheme.primary,
              overlayColor: scheme.primary.withValues(alpha: 0.1),
              padding: EdgeInsets.zero,
            ),
            child: SizedBox(
              height: 20,
              child: Slider(
                value: progress,
                onChanged: canSeek
                    ? (value) {
                        onSeekPreview(
                          Duration(
                            milliseconds: (duration.inMilliseconds * value)
                                .round(),
                          ),
                        );
                      }
                    : null,
                onChangeEnd: canSeek
                    ? (value) {
                        onSeekEnd(
                          Duration(
                            milliseconds: (duration.inMilliseconds * value)
                                .round(),
                          ),
                        );
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayingDots extends StatefulWidget {
  const _PlayingDots({required this.color});

  final Color color;

  @override
  State<_PlayingDots> createState() => _PlayingDotsState();
}

class _PlayingDotsState extends State<_PlayingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.22) % 1.0;
            final h = 4.0 + 6.0 * (1 - (2 * t - 1).abs());
            return Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 2),
              child: Container(
                width: 2.5,
                height: h,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PlayerTransportButton extends StatelessWidget {
  const _PlayerTransportButton({
    required this.onPressed,
    required this.primary,
    required this.onPrimary,
    required this.child,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final Color primary;
  final Color onPrimary;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 50.0;
    return Material(
      color: primary,
      shape: const CircleBorder(),
      elevation: compact ? 2 : 3,
      shadowColor: primary.withValues(alpha: 0.4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _SeekChip extends StatelessWidget {
  const _SeekChip({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = enabled
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.28);
    return Material(
      color: enabled
          ? scheme.primary.withValues(alpha: 0.09)
          : scheme.onSurface.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

class _DetailTabBody extends StatelessWidget {
  const _DetailTabBody({
    required this.pageController,
    required this.onPageChanged,
    required this.lyric,
    required this.localPartitionPath,
    required this.partitionDownloading,
    required this.onOpenPartitionExternally,
    required this.onDownloadPartition,
    required this.bottomContentPadding,
  });

  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final Lyric lyric;
  final String? localPartitionPath;
  final bool partitionDownloading;
  final ValueChanged<String> onOpenPartitionExternally;
  final VoidCallback onDownloadPartition;
  final double bottomContentPadding;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: [
        _TabPageScroll(
          bottomPadding: bottomContentPadding,
          child: _LyricsTabContent(lyric: lyric),
        ),
        _TabPageScroll(
          bottomPadding: bottomContentPadding,
          center: true,
          child: _SheetMusicTabContent(
            lyric: lyric,
            localPartitionPath: localPartitionPath,
            partitionDownloading: partitionDownloading,
            onOpenPartitionExternally: onOpenPartitionExternally,
            onDownloadPartition: onDownloadPartition,
          ),
        ),
        _TabPageScroll(
          bottomPadding: bottomContentPadding,
          center: true,
          child: const _SongHistoryComingSoon(),
        ),
        _TabPageScroll(
          bottomPadding: bottomContentPadding,
          child: ProjectionTabContent(lyric: lyric),
        ),
      ],
    );
  }
}

class _TabPageScroll extends StatelessWidget {
  const _TabPageScroll({
    required this.child,
    required this.bottomPadding,
    this.center = false,
  });

  final Widget child;
  final double bottomPadding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = center
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - bottomPadding).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Center(child: child),
              )
            : child;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: content,
        );
      },
    );
  }
}

class _LyricsTabContent extends StatelessWidget {
  const _LyricsTabContent({required this.lyric});

  final Lyric lyric;

  @override
  Widget build(BuildContext context) {
    final chorusPlain = lyric.chorus.stripHtmlTags;
    final verses = lyric.enLyrics;
    final scheme = Theme.of(context).colorScheme;
    final numberPrefix = lyric.displayNumber.isNotEmpty
        ? '${lyric.displayNumber}. '
        : '';
    final titleText = '$numberPrefix${lyric.songTitle.capitalize}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/logo2.png',
                fit: BoxFit.fitWidth,
                width: double.infinity,
                alignment: Alignment.center,
                opacity: AlwaysStoppedAnimation(
                  Theme.of(context).brightness == Brightness.dark ? 0.07 : 0.10,
                ),
                cacheWidth: imageCachePx(context, 320),
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: scheme.onSurface,
                ),
              ),
              if (lyric.author.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  lyric.author,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _MetadataChips(lyric: lyric),
              const SizedBox(height: 20),
              if (verses.isNotEmpty) LyricItem(index: 1, verse: verses.first),
              if (chorusPlain.isNotEmpty) ...[
                const SizedBox(height: 28),
                _ChorusBlock(chorus: lyric.chorus),
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
        ],
      ),
    );
  }
}

class _MetadataChips extends StatelessWidget {
  const _MetadataChips({required this.lyric});

  final Lyric lyric;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final year = lyric.displayYear.isNotEmpty
        ? lyric.displayYear
        : l10n.notAvailable;
    final key = lyric.key.isNotEmpty ? lyric.key : l10n.notAvailable;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _MetadataChip(label: l10n.composedLabel, value: year),
        _MetadataChip(label: l10n.keyLabel, value: key),
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: fill,
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
}

class _SheetMusicTabContent extends StatelessWidget {
  const _SheetMusicTabContent({
    required this.lyric,
    required this.localPartitionPath,
    required this.partitionDownloading,
    required this.onOpenPartitionExternally,
    required this.onDownloadPartition,
  });

  final Lyric lyric;
  final String? localPartitionPath;
  final bool partitionDownloading;
  final ValueChanged<String> onOpenPartitionExternally;
  final VoidCallback onDownloadPartition;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = localPartitionPath;
    final hasLocal = path != null;
    final hasRemote = lyric.partitionUrl.isNotEmpty;

    if (hasLocal && _isImagePartitionPath(path)) {
      return _PartitionImageView(
        key: ValueKey('sheet_music_image_$path'),
        path: path,
      );
    }

    if (hasLocal && _isPdfPartitionPath(path)) {
      return _PartitionPdfView(
        key: ValueKey('sheet_music_pdf_$path'),
        path: path,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyText = hasLocal
        ? l10n.partitionSavedLocal
        : hasRemote
        ? l10n.partitionTapDownload
        : l10n.partitionNone;
    const radius = 24.0;
    const borderWidth = 1.5;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: isDark ? 0.55 : 0.35),
                scheme.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                scheme.primary.withValues(alpha: isDark ? 0.45 : 0.28),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: isDark ? 0.1 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - borderWidth),
            child: ColoredBox(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? const [Color(0xFF2C231F), Color(0xFF181412)]
                        : const [Color(0xFFFFFCF9), Color(0xFFF8EDE6)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 3,
                      width: double.infinity,
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 58,
                              height: 58,
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
                                hasLocal
                                    ? LucideIcons.fileMusic
                                    : hasRemote
                                    ? LucideIcons.download
                                    : LucideIcons.music,
                                size: 26,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.sheetMusicHeading,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fraunces(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bodyText,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 13.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          if (hasLocal || hasRemote) ...[
                            const SizedBox(height: 22),
                            if (partitionDownloading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: AppProgressIndicator(),
                                ),
                              )
                            else
                              Center(
                                child: FilledButton.icon(
                                  onPressed: hasLocal
                                      ? () => onOpenPartitionExternally(path)
                                      : onDownloadPartition,
                                  icon: Icon(
                                    hasLocal
                                        ? LucideIcons.externalLink
                                        : LucideIcons.download,
                                    size: 18,
                                  ),
                                  label: Text(
                                    hasLocal
                                        ? l10n.openExternally
                                        : l10n.download,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeColors.darkTrack(scheme)
                    : AppThemeColors.lightTrack,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.zoomIn, size: 14, color: muted),
                  const SizedBox(width: 6),
                  Text(
                    l10n.pinchToZoom,
                    style: GoogleFonts.ibmPlexSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.08 : 0.05,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: ColoredBox(
                  color: isDark
                      ? const Color(0xFF1A1614)
                      : const Color(0xFFFFFCF9),
                  child: SizedBox(
                    height: viewerHeight,
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5.0,
                      child: Image.file(
                        File(path),
                        fit: BoxFit.contain,
                        cacheWidth: imageCachePx(
                          context,
                          MediaQuery.sizeOf(context).width,
                        ),
                        cacheHeight: imageCachePx(context, viewerHeight),
                        errorBuilder: (_, _, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.imageOff,
                                size: 48,
                                color: scheme.onSurface.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 8),
                              Text(l10n.couldNotDisplayImage),
                            ],
                          ),
                        ),
                      ),
                    ),
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
    _bitmapCache.clear();
    _bitmapFutureCache.clear();
    final doc = _document;
    _document = null;
    _openError = null;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ColoredBox(
      color: bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeColors.darkTrack(scheme)
                    : AppThemeColors.lightTrack,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.moveHorizontal, size: 14, color: muted),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.pinchToZoomPdf,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: muted,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.24 : 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.08 : 0.05,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: ColoredBox(
                  color: isDark
                      ? const Color(0xFF1A1614)
                      : const Color(0xFFFFFCF9),
                  child: SizedBox(
                    height: viewerHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(
                            parent: PageScrollPhysics(),
                          ),
                          itemCount: _pageCount,
                          onPageChanged: (i) =>
                              setState(() => _currentPage = i + 1),
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final dpr = MediaQuery.devicePixelRatioOf(
                                  context,
                                );
                                final mw = (constraints.maxWidth * dpr)
                                    .round()
                                    .clamp(1, 8192);
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
                                            l10n.couldNotDisplayPdf(
                                              '${snap.error}',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      );
                                    }
                                    return _PartitionPdfZoomPage(
                                      bytes: snap.data!,
                                    );
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
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeColors.darkTrack(scheme)
                    : AppThemeColors.lightTrack,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: isDark ? 0.22 : 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
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
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
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
    final maxDots = pageCount.clamp(1, 8);
    // Map current page into a capped indicator window for long PDFs.
    final activeDot = pageCount <= maxDots
        ? (currentPage - 1).clamp(0, maxDots - 1)
        : (((currentPage - 1) / (pageCount - 1)) * (maxDots - 1)).round().clamp(
            0,
            maxDots - 1,
          );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxDots, (i) {
          final active = i == activeDot;
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

class _SongHistoryComingSoon extends StatelessWidget {
  const _SongHistoryComingSoon();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      key: const ValueKey('song_history'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.bookOpenText,
              size: 40,
              color: scheme.primary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.songHistoryComingSoonTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.songHistoryComingSoonBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double visibility;
  final double extent;
  final String lyricsLabel;
  final String sheetMusicLabel;
  final String projectionLabel;
  final String songHistoryLabel;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isEnglish;
  final String frenchLabel;
  final String englishLabel;
  final VoidCallback onSelectFrench;
  final VoidCallback onSelectEnglish;

  _TabHeaderDelegate({
    required this.visibility,
    required this.extent,
    required this.lyricsLabel,
    required this.sheetMusicLabel,
    required this.projectionLabel,
    required this.songHistoryLabel,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isEnglish,
    required this.frenchLabel,
    required this.englishLabel,
    required this.onSelectFrench,
    required this.onSelectEnglish,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    if (extent <= 0) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;
    final labels = [
      lyricsLabel,
      sheetMusicLabel,
      songHistoryLabel,
      projectionLabel,
    ];
    final t = visibility.clamp(0.0, 1.0);

    return SizedBox(
      height: extent,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ClipRect(
          child: Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, -10 * (1 - t)),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: trackColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              for (var i = 0; i < labels.length; i++)
                                _DetailTabBarItem(
                                  label: labels[i],
                                  selected: selectedIndex == i,
                                  onTap: () => onTabSelected(i),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      LanguageToggle(
                        subtle: true,
                        isEnglish: isEnglish,
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
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => extent < 0 ? 0.0 : extent;

  @override
  double get minExtent => extent < 0 ? 0.0 : extent;

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) {
    return oldDelegate.visibility != visibility ||
        oldDelegate.extent != extent ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isEnglish != isEnglish ||
        oldDelegate.lyricsLabel != lyricsLabel ||
        oldDelegate.sheetMusicLabel != sheetMusicLabel ||
        oldDelegate.projectionLabel != projectionLabel ||
        oldDelegate.songHistoryLabel != songHistoryLabel;
  }
}

class _DetailTabBarItem extends StatelessWidget {
  const _DetailTabBarItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = scheme.onSurface.withValues(alpha: 0.34);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: isDark ? 0.14 : 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: GoogleFonts.ibmPlexSans(
              fontSize: 10.5,
              height: 1.1,
              letterSpacing: 0.15,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? scheme.primary : muted,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
