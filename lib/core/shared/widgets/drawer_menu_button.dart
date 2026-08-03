import 'package:fgm_lyrics_app/core/shared/widgets/app_nav_scope.dart';
import 'package:fgm_lyrics_app/core/theme/app_fonts.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:fgm_lyrics_app/core/utils/image_decode.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Opens the floating navigation menu sheet.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: () => showAppNavigationSheet(context),
      icon: Icon(
        LucideIcons.menu,
        size: 22,
        color: scheme.onSurface.withValues(alpha: 0.72),
      ),
    );
  }
}

Future<void> showAppNavigationSheet(BuildContext context) {
  final nav = AppNavScope.of(context);
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bottomInset = MediaQuery.paddingOf(context).bottom;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: isDark ? 0.55 : 0.35),
    isScrollControlled: true,
    useRootNavigator: false,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 12 + bottomInset),
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: scheme.primary.withValues(alpha: isDark ? 0.28 : 0.12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF2C231F), Color(0xFF181412)]
                    : const [Color(0xFFFFFCF9), Color(0xFFF3EDE4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: _AppNavigationSheet(
                selectedIndex: nav.selectedIndex,
                onSelect: (index) {
                  Navigator.of(sheetContext).pop();
                  nav.onSelect(index);
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _AppNavigationSheet extends StatelessWidget {
  const _AppNavigationSheet({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Row(
            children: [
              Image.asset(
                'assets/logo2.png',
                width: 42,
                height: 42,
                opacity: const AlwaysStoppedAnimation(0.85),
                cacheWidth: imageCachePx(context, 42),
                cacheHeight: imageCachePx(context, 42),
                filterQuality: FilterQuality.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: TextStyle(
                        fontFamily: AppFonts.fraunces,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.appBrandTagline,
                      style: TextStyle(
                        fontFamily: AppFonts.ibmPlexSans,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(
                  LucideIcons.x,
                  size: 20,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  scheme.primary.withValues(alpha: 0.08),
                  scheme.primary.withValues(alpha: 0.45),
                  scheme.primary.withValues(alpha: 0.08),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            children: [
              _NavTile(
                icon: LucideIcons.house,
                label: l10n.navHome,
                selected: selectedIndex == 0,
                onTap: () => onSelect(0),
              ),
              _NavTile(
                icon: LucideIcons.star,
                label: l10n.navFavorites,
                selected: selectedIndex == 1,
                onTap: () => onSelect(1),
              ),
              _NavTile(
                icon: LucideIcons.settings,
                label: l10n.navSettings,
                selected: selectedIndex == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
          child: Text(
            l10n.splashOrganizationName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.ibmPlexSans,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected
        ? scheme.primary
        : scheme.onSurface.withValues(alpha: 0.55);
    final track = isDark
        ? AppThemeColors.darkTrack(scheme)
        : AppThemeColors.lightTrack;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: isDark ? 0.16 : 0.09)
            : track,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.08),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.ibmPlexSans,
                      fontSize: 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.1,
                      color: color,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: scheme.primary.withValues(alpha: 0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
