import 'package:fgm_lyrics_app/app/favorite/favorite_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/lyric_detail_screen.dart';
import 'package:fgm_lyrics_app/core/models/lyric.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/string_extension.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LyricTile extends ConsumerWidget {
  const LyricTile({super.key, required this.lyric, this.secondaryTitle});

  final Lyric lyric;

  /// Title in the other language, shown under the primary title.
  final String? secondaryTitle;

  String get _favoriteKey => lyric.id.toString();

  String _badgeNumber() {
    final display = lyric.displayNumber.trim();
    if (display.isEmpty) return '—';
    final parsed = int.tryParse(display);
    if (parsed != null && parsed >= 0 && parsed < 100) {
      return parsed.toString().padLeft(2, '0');
    }
    return display.length > 3 ? display.substring(0, 3) : display;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavoriteAsync = ref.watch(isFavoriteProvider(_favoriteKey));
    final isFavorite = isFavoriteAsync.value ?? false;

    final title = lyric.songTitle.trim().isEmpty
        ? l10n.untitledHymn
        : lyric.songTitle.capitalize;
    final subtitle = secondaryTitle?.trim();
    final showSubtitle =
        subtitle != null &&
        subtitle.isNotEmpty &&
        subtitle.toLowerCase() != lyric.songTitle.trim().toLowerCase();

    return InkWell(
      onTap: () => context.push(LyricDetailScreen(lyric: lyric)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NumberBadge(
              number: _badgeNumber(),
              primary: scheme.primary,
              background: isDark
                  ? scheme.primary.withValues(alpha: 0.18)
                  : scheme.primary.withValues(alpha: 0.08),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fraunces(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle.capitalize,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: scheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: isFavorite
                  ? l10n.removeFromFavorites
                  : l10n.addToFavorites,
              onPressed: () async {
                await ref
                    .read(favoriteNotifierProvider.notifier)
                    .toggleFavorite(lyric.id);
              },
              icon: Icon(
                LucideIcons.heart,
                size: 22,
                color: isFavorite
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: scheme.onSurface.withValues(alpha: 0.28),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge({
    required this.number,
    required this.primary,
    required this.background,
  });

  final String number;
  final Color primary;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.fraunces(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF2EAE5B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
