import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:upgrader/upgrader.dart';

/// Brand-styled force-update dialog for [UpgradeAlert].
class StyledUpgradeAlert extends UpgradeAlert {
  StyledUpgradeAlert({
    super.key,
    super.child,
    super.upgrader,
    super.navigatorKey,
    super.barrierDismissible = false,
    super.showIgnore = false,
    super.showLater = false,
    super.showPrompt = true,
    super.showReleaseNotes = true,
    super.shouldPopScope,
    super.onUpdate,
  });

  @override
  UpgradeAlertState createState() => _StyledUpgradeAlertState();
}

class _StyledUpgradeAlertState extends UpgradeAlertState {
  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    if (widget.upgrader.state.debugLogging) {
      debugPrint('upgrader: showTheDialog (styled) title: $title');
    }

    if (!context.mounted) return;

    widget.upgrader.saveLastAlerted();

    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final l10n = AppLocalizations.of(dialogContext);
        final appName = l10n?.appTitle ?? 'FGM Hymnals';
        final dialogTitle =
            l10n?.upgradeDialogTitle ?? title ?? 'Update available';
        final dialogBody = l10n?.upgradeDialogBody(appName) ?? message;
        final prompt =
            l10n?.upgradeDialogPrompt ??
            messages.message(UpgraderMessage.prompt) ??
            '';
        final updateLabel =
            l10n?.upgradeDialogUpdate ??
            messages.message(UpgraderMessage.buttonTitleUpdate) ??
            'Update';
        final notesLabel =
            l10n?.upgradeDialogReleaseNotes ??
            messages.message(UpgraderMessage.releaseNotes) ??
            'What’s new';

        return PopScope(
          canPop: onCanPop(),
          child: Dialog(
            key: key,
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.32 : 0.14,
                    ),
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
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.45 : 0.16,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(27),
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
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
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
                                LucideIcons.download,
                                color: scheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              dialogTitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.fraunces(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 220),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Text(
                                      dialogBody,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.ibmPlexSans(
                                        fontSize: 14.5,
                                        height: 1.45,
                                        fontWeight: FontWeight.w500,
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    ),
                                    if (widget.showPrompt &&
                                        prompt.trim().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        prompt,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.ibmPlexSans(
                                          fontSize: 13.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w600,
                                          color: scheme.primary.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (widget.showReleaseNotes &&
                                        releaseNotes != null &&
                                        releaseNotes.trim().isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          notesLabel,
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.4,
                                            color: scheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          releaseNotes,
                                          style: GoogleFonts.ibmPlexSans(
                                            fontSize: 13,
                                            height: 1.4,
                                            fontWeight: FontWeight.w500,
                                            color: scheme.onSurface.withValues(
                                              alpha: 0.65,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => onUserUpdated(
                                  dialogContext,
                                  !widget.upgrader.blocked(),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Text(
                                  updateLabel,
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
        );
      },
    );
  }
}
