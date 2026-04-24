import 'package:fgm_lyrics_app/app/data/payment_model.dart';
import 'package:fgm_lyrics_app/app/payment/payment_provider.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/payunit_config.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/core/widgets/app_headline_text.dart';
import 'package:fgm_lyrics_app/core/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayWallScreen extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const PayWallScreen({super.key, required this.onTap});

  @override
  ConsumerState<PayWallScreen> createState() => _PayWallScreenState();
}

class _PayWallScreenState extends ConsumerState<PayWallScreen> {
  bool isLoading = false;
  Future<void> _initializePayment() async {
    setState(() => isLoading = true);
    const payment = Payment(
      amount: PayUnitConfig.appPrice,
      currency: PayUnitConfig.currency,
    );

    await ref
        .read(paymentProvider.notifier)
        .initializePayment(
          payment: payment,
          returnUrl: PayUnitConfig.returnUrl,
          notifyUrl: PayUnitConfig.notifyUrl,
        );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverToBoxAdapter(
      child: AppDefaultSpacing(
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: isLoading,
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
                const GutterLarge(),

                ElevatedButton.icon(
                  // onPressed: paymentState.isLoading ? null : _handlePayment,
                  // child: paymentState.isLoading
                  //     ? const SizedBox(
                  //         height: 20,
                  //         width: 20,
                  //         child: CircularProgressIndicator(strokeWidth: 2),
                  //       )
                  //     : Text(_getButtonText(paymentState)),
                  onPressed: () async {
                    await _initializePayment();
                    widget.onTap();
                  },
                  label: isLoading
                      ? Text(l10n.payWallLoading)
                      : Text(l10n.payWallContinue),
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: AppProgressIndicator(),
                        )
                      : null,
                ),
                const Gutter(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.payWallAlreadyPurchased),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.payWallClickHere,
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
}


// Show payment methods if payment is initialized - Step 2
// if (paymentState.initializeResponse != null)