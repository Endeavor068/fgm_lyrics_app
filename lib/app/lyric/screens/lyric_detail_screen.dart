// import 'package:audioplayers/audioplayers.dart' show AudioPlayer;
import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

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
  String _getAudioSource() {
    return 'songs/${widget.lyric.id}.mp3';
  }

  /// Checks if the audio file exists in the assets
  Future<bool> _audioFileExists() async {
    try {
      final String assetPath = 'assets/${_getAudioSource()}';
      await DefaultAssetBundle.of(context).load(assetPath);
      return true;
    } catch (e) {
      debugPrint('Audio file does not exist: ${_getAudioSource()}');
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

  Future<void> _checkAudioAvailability() async {
    final bool audioFileExists = await _audioFileExists();
    if (mounted) setState(() => _audioFileAvailable = audioFileExists);
  }

  @override
  void didChangeDependencies() async {
    await _checkAudioAvailability();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Gets a randomized religious image URL based on songId for consistency
  // String _getReligiousImageUrl() {
  //   // // List of free religious images from Unsplash
  //   // final List<String> religiousImages = [
  //   //   "https://images.unsplash.com/photo-1520446266423-6daca23fe8c7?q=80&w=2940&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  //   // ];

  //   // // Use songId as seed for consistent image per song
  //   // final index = widget.lyric.songId % religiousImages.length;
  //   // return religiousImages[index];
  // }

  /// Favorite key: id can be int (e.g. 1) or string (e.g. "160A").
  String get _favoriteIdKey => widget.lyric.id.toString();

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
                          '${widget.lyric.songTitle.capitalize} - FGM Hymns',
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
                            Text(
                              "${widget.lyric.id}. ",
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
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

      // Audio Player at Bottom
      // bottomSheet: _buildAudioPlayer(),
      floatingActionButton: _audioFileAvailable
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () async {
                if (!_animationController.isCompleted) {
                  _animationController.forward();
                  try {
                    await _audioPlayer.play(AssetSource(_getAudioSource()));
                  } catch (e) {
                    debugPrint('Error playing audio: $e');
                    _animationController.reverse();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Audio file could not be played'),
                        ),
                      );
                    }
                  }
                } else {
                  await _audioPlayer.pause();
                  _animationController.reverse();
                }
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _animationController,
                color: Theme.of(context).cardColor,
                size: 40,
              ),
            )
          : FloatingActionButton(
              backgroundColor: Theme.of(context).disabledColor,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Audio file not available for this hymn'),
                  ),
                );
              },
              child: Icon(
                Icons.music_off,
                color: Theme.of(context).cardColor,
                size: 40,
              ),
            ),
    );
  }

  Widget _buildMetadataGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Composed',
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
                extractComposedYear(),
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
                'Key',
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
                widget.lyric.key.isNotEmpty ? widget.lyric.key : 'N/A',
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
              textAlign: TextAlign.center,
              widget.lyric.chorus,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
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

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       '${widget.lyric.enLyrics.indexOf(verse) + 1}.',
                  //       style: Theme.of(context).textTheme.bodyLarge
                  //           ?.copyWith(fontWeight: FontWeight.bold),
                  //     ),
                  //     const Gutter(),
                  //     Text(
                  //       textAlign: TextAlign.center,
                  //       verse,
                  //       style: Theme.of(context).textTheme.bodyLarge
                  //           ?.copyWith(
                  //             height: 1.6,
                  //             color: Theme.of(
                  //               context,
                  //             ).textTheme.bodyLarge?.color,
                  //           ),
                  //     ),
                  //   ],
                  // ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSheetMusicContent() {
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
          Icon(Icons.music_note, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Sheet Music',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const GutterSmall(),
          Text(
            'Sheet music content will be displayed here',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget _buildAudioPlayer() {
  //   return Container(
  //     height: 80,
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Theme.of(context).shadowColor.withAlpha(40),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Row(
  //         children: [
  //           // Play button
  //           IconButton.filled(
  //             onPressed: () {
  //               if (!_animationController.isCompleted) {
  //                 _animationController.forward();
  //               } else {
  //                 _animationController.reverse();
  //               }
  //             },
  //             icon: AnimatedIcon(
  //               icon: AnimatedIcons.play_pause,
  //               progress: _animationController,
  //               color: Theme.of(context).cardColor,
  //               size: 40,
  //             ),
  //           ),

  //           const SizedBox(width: 16),

  //           // Progress bar and time
  //           Expanded(
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Progress bar
  //                 Container(
  //                   height: 4,
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey,
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   child: FractionallySizedBox(
  //                     alignment: Alignment.centerLeft,
  //                     widthFactor: 0.3, // 30% progress
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: Theme.of(context).colorScheme.primary,
  //                         borderRadius: BorderRadius.circular(4),
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 const GutterSmall(),

  //                 // Time display
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       '1:02',
  //                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                         color: Colors.grey.shade600,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     Text(
  //                       '3:24',
  //                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                         color: Colors.grey.shade600,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  /// Extracts the composed year from the author field
  /// Returns the year if found, otherwise returns null
  /// Examples:
  /// - "John Doe (1850)" -> "1850"
  /// - "Jane Smith, 1920" -> "1920"
  /// - "Author Name - 1789" -> "1789"
  /// - "1865, Unknown Author" -> "1865"
  String extractComposedYear() {
    if (widget.lyric.author.isEmpty) return 'N/A';

    // Regex to match 4-digit years (1000-2999)
    final RegExp yearRegex = RegExp(r'\b(1[0-9]{3}|2[0-9]{3})\b');
    final match = yearRegex.firstMatch(widget.lyric.author);

    return match?.group(1) ?? 'N/A';
  }

  String get hymnText {
    return "*${widget.lyric.id}.  ${widget.lyric.songTitle}*\n\n"
        "${widget.lyric.enLyrics.first}\n\n\n"
        "${widget.lyric.chorus.isNotEmpty
            ? ref.watch(deviceLocaleProvider) == LanguageEnum.en.name
                  ? "*Chorus :*\n"
                  : "*Refrain :*\n"
            : ''}"
        "${widget.lyric.chorus.isNotEmpty ? "${widget.lyric.chorus}\n\n\n" : ''}"
        "${widget.lyric.enLyrics.length > 1 ? widget.lyric.enLyrics.sublist(1, widget.lyric.enLyrics.length - 1).map((lyric) => "${lyric.trim()}\n\n").join(' ').toString() : ''}";
  }
}

class LyricItem extends StatelessWidget {
  const LyricItem({super.key, required this.verse, required this.index});

  final String verse;
  final int index;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$index.',
            style: textStyle?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Gutter(),
          Expanded(
            child: Text(
              verse,
              style: textStyle?.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final Function(int) onTabSelected;

  _TabHeaderDelegate({
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
                      'Lyrics',
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
                      'Sheet Music',
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
