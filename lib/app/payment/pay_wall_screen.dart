import 'package:fgm_lyrics_app/app/payment/payment_provider.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/core/widgets/app_headline_text.dart';
import 'package:fgm_lyrics_app/core/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PayWallScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const PayWallScreen({super.key, required this.onUnlocked});

  @override
  ConsumerState<PayWallScreen> createState() => _PayWallScreenState();
}

class _PayWallScreenState extends ConsumerState<PayWallScreen> {
  bool _hasShownSuccessDialog = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final purchaseState = ref.watch(purchaseProvider);

    ref.listen(purchaseProvider, (previous, next) {
      if (next.hasFullAccess && !_hasShownSuccessDialog) {
        _hasShownSuccessDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showSuccessDialog(context);
        });
      }
    });

    return SliverToBoxAdapter(
      child: AppDefaultSpacing(
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: purchaseState.isBusy,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo_pay.png', height: 250),
                AppHeadlineText(text: l10n.payWallTitle),
                const GutterTiny(),
                Text(
                  l10n.payWallBody,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .5),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (purchaseState.formattedPrice != null) ...[
                  const Gutter(),
                  Text(
                    purchaseState.formattedPrice!,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const GutterLarge(),
                if (!purchaseState.isStoreAvailable)
                  Text(
                    l10n.payWallStoreUnavailable,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  )
                else if (purchaseState.errorMessage != null)
                  Text(
                    _errorMessage(l10n, purchaseState.errorMessage!),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (purchaseState.isStoreAvailable) ...[
                  const Gutter(),
                  ElevatedButton.icon(
                    onPressed:
                        purchaseState.product == null || purchaseState.isBusy
                        ? null
                        : () => ref
                              .read(purchaseProvider.notifier)
                              .buyFullAccess(),
                    label: Text(
                      purchaseState.isPurchasing
                          ? l10n.paymentProcessing
                          : l10n.payWallPurchase,
                    ),
                    icon: purchaseState.isBusy
                        ? const AppProgressIndicator(size: 20, strokeWidth: 2.4)
                        : null,
                  ),
                ],
                const Gutter(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.payWallAlreadyPurchased),
                    TextButton(
                      onPressed: purchaseState.isBusy
                          ? null
                          : () => ref
                                .read(purchaseProvider.notifier)
                                .restorePurchases(),
                      child: Text(
                        purchaseState.isRestoring
                            ? l10n.payWallRestoreInProgress
                            : l10n.payWallRestore,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, String code) {
    return switch (code) {
      'product_not_found' => l10n.payWallProductNotFound,
      'product_load_failed' => l10n.payWallProductLoadError,
      'purchase_start_failed' => l10n.payWallPurchaseStartFailed,
      'purchase_failed' => l10n.payWallPurchaseFailed,
      'restore_failed' => l10n.payWallRestoreFailed,
      _ => code,
    };
  }

  void _showSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          insetPadding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.green.withValues(alpha: .5)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.circleCheck,
                  size: 60,
                  color: Colors.green,
                ),
                const Gutter(),
                Text(
                  l10n.paymentSuccessTitle,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const GutterSmall(),
                Text(
                  l10n.paymentSuccessBody,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: .5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gutter.custom(size: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    widget.onUnlocked();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    l10n.paymentSuccessContinue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
