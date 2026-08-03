import 'package:fgm_lyrics_app/app/harmonyforge/harmonyforge_media_service.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_controller.dart';
import 'package:fgm_lyrics_app/app/lyric/lyric_repository.dart';
import 'package:fgm_lyrics_app/app/notifications/praise_notification_provider.dart';
import 'package:fgm_lyrics_app/app/notifications/praise_notification_service.dart';
import 'package:fgm_lyrics_app/app/settings/typography_settings_provider.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/drawer_menu_button.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/scroll_hide_chrome.dart';
import 'package:fgm_lyrics_app/core/utils/app_links.dart';
import 'package:fgm_lyrics_app/core/widgets/hymn_text_display.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key, this.chromeVisible = true});

  /// When false, the app bar collapses (scroll-hide chrome from parent shell).
  final bool chromeVisible;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isRefreshing = false;
  bool _isClearing = false;

  // ── Refresh ───────────────────────────────────────────────────────────────

  Future<void> _refreshFromServer() async {
    if (_isRefreshing) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(englishHymnProvider);
      ref.invalidate(frenchHymnProvider);
      await Future.wait([
        ref.read(englishHymnProvider.future),
        ref.read(frenchHymnProvider.future),
      ]);
      _showSnackBar(l10n.hymnsUpdatedSuccess);
    } catch (_) {
      _showSnackBar(l10n.couldNotReachServer);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // ── Clear data ────────────────────────────────────────────────────────────

  Future<void> _clearAllDownloadedData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmationDialog(
      title: l10n.clearDataDialogTitle,
      message: l10n.clearDataDialogMessage,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );
    if (!confirmed) return;

    setState(() => _isClearing = true);
    try {
      final media = ref.read(harmonyForgeMediaServiceProvider);
      final sync = ref.read(harmonyForgeSyncServiceProvider);
      await Future.wait([
        media.clearDownloadedAudio(),
        media.clearDownloadedPartitions(),
        sync.clearCache(),
      ]);
      ref.invalidate(englishHymnProvider);
      ref.invalidate(frenchHymnProvider);
      _showSnackBar(l10n.downloadedDataCleared);
    } catch (_) {
      _showSnackBar(l10n.failedToClearData);
    } finally {
      if (mounted) setState(() => _isClearing = false);
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(AppLinks.privacyPolicy);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showSnackBar(l10n.privacyPolicyOpenFailed);
      }
    } catch (_) {
      if (mounted) _showSnackBar(l10n.privacyPolicyOpenFailed);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final busy = _isRefreshing || _isClearing;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScrollHideChrome(
            visible: widget.chromeVisible,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: kToolbarHeight,
                  child: NavigationToolbar(
                    centerMiddle: false,
                    leading: const DrawerMenuButton(),
                    middle: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.settingsTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AbsorbPointer(
              absorbing: busy,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _SectionHeader(label: l10n.appearanceSection),
                  const _ThemeTile(),
                  const Divider(height: 1, indent: 16),
                  const _FontSizeTile(),
                  const Divider(height: 1, indent: 16),
                  const _FontFamilyTile(),
                  _SectionHeader(label: l10n.remindersSection),
                  const _PraiseRemindersTile(),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: LucideIcons.bellRing,
                    title: l10n.testNotificationTitle,
                    subtitle: l10n.testNotificationSubtitle,
                    onTap: () async {
                      final granted = await PraiseNotificationService.instance
                          .requestPermissionIfNeeded();
                      if (!granted) {
                        _showSnackBar(l10n.testNotificationPermissionDenied);
                        return;
                      }
                      await PraiseNotificationService.instance
                          .showTestNotification();
                      if (mounted) {
                        _showSnackBar(l10n.testNotificationSent);
                      }
                    },
                  ),
                  _SectionHeader(label: l10n.dataSection),
                  _SettingsTile(
                    icon: LucideIcons.refreshCw,
                    title: l10n.refreshHymnsTitle,
                    subtitle: l10n.refreshHymnsSubtitle,
                    loading: _isRefreshing,
                    onTap: _refreshFromServer,
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsTile(
                    icon: LucideIcons.trash2,
                    iconColor: Theme.of(context).colorScheme.error,
                    title: l10n.clearDataTitle,
                    subtitle: l10n.clearDataSubtitle,
                    loading: _isClearing,
                    onTap: _clearAllDownloadedData,
                    titleColor: Theme.of(context).colorScheme.error,
                  ),
                  _SectionHeader(label: l10n.legalSection),
                  _SettingsTile(
                    icon: LucideIcons.shieldCheck,
                    title: l10n.privacyPolicyTitle,
                    subtitle: l10n.privacyPolicySubtitle,
                    onTap: _openPrivacyPolicy,
                    trailing: const Icon(LucideIcons.externalLink, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appearance tiles ──────────────────────────────────────────────────────────

class _PraiseRemindersTile extends ConsumerWidget {
  const _PraiseRemindersTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(praiseRemindersProvider);
    return SwitchListTile(
      secondary: const Icon(LucideIcons.bell),
      title: Text(
        l10n.praiseRemindersTitle,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(l10n.praiseRemindersSubtitle),
      value: enabled,
      onChanged: (value) =>
          ref.read(praiseRemindersProvider.notifier).setEnabled(value),
    );
  }
}

/// Three-way theme selector: Light / System / Dark.
class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(LucideIcons.sunMoon),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.brightness,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(LucideIcons.sun),
                      label: Text(l10n.themeLight),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(LucideIcons.sunMoon),
                      label: Text(l10n.themeSystem),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(LucideIcons.moon),
                      label: Text(l10n.themeDark),
                    ),
                  ],
                  selected: {current},
                  onSelectionChanged: (s) =>
                      ref.read(themeProvider.notifier).setTheme(s.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Slider to adjust the hymn text font size with a live preview.
class _FontSizeTile extends ConsumerWidget {
  const _FontSizeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final size = ref.watch(fontSizeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.aLargeSmall),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.fontSize,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      l10n.fontSizePt('${size.round()}'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: size,
                  min: kMinFontSize,
                  max: kMaxFontSize,
                  divisions: (kMaxFontSize - kMinFontSize).round(),
                  onChanged: (v) =>
                      ref.read(fontSizeProvider.notifier).setFontSize(v),
                ),
                // Live preview
                Builder(
                  builder: (context) {
                    final scheme = Theme.of(context).colorScheme;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? scheme.onSurface.withValues(alpha: 0.08)
                            : const Color(0xFFF0E9DF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.primary.withValues(
                            alpha: isDark ? 0.22 : 0.12,
                          ),
                        ),
                      ),
                      child: HymnTextDisplay(
                        text: l10n.fontPreviewSample,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip selector for the hymn text font family with a live preview.
class _FontFamilyTile extends ConsumerWidget {
  const _FontFamilyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.watch(fontFamilyProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.type),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fontFamily,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final scheme = Theme.of(context).colorScheme;
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final track = isDark
                        ? scheme.onSurface.withValues(alpha: 0.08)
                        : const Color(0xFFF0E9DF);
                    final border = scheme.primary.withValues(
                      alpha: isDark ? 0.22 : 0.12,
                    );
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HymnFontFamily.values.map((family) {
                        final selected = family == current;
                        return ChoiceChip(
                          showCheckmark: false,
                          selected: selected,
                          onSelected: (_) => ref
                              .read(fontFamilyProvider.notifier)
                              .setFontFamily(family),
                          backgroundColor: track,
                          selectedColor: scheme.primary.withValues(
                            alpha: isDark ? 0.22 : 0.14,
                          ),
                          side: BorderSide(color: border),
                          label: Text(
                            family.displayName,
                            style: family
                                .textStyle(fontSize: 13)
                                .copyWith(
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? scheme.primary
                                      : scheme.onSurface.withValues(
                                          alpha: 0.55,
                                        ),
                                ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared setting tiles ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
    this.loading = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;
  final bool loading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: loading
          ? AppProgressIndicator(
              size: 24,
              strokeWidth: 2.4,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
            )
          : Icon(icon, color: iconColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: trailing,
      onTap: loading ? null : onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
