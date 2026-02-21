import 'package:fgm_lyrics_app/app/payment/payment_provider.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/core/widgets/app_headline_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const PaymentMethodScreen({super.key, required this.onTap});

  @override
  ConsumerState<PaymentMethodScreen> createState() =>
      _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider).requireValue;
    return SliverToBoxAdapter(
      child: AppDefaultSpacing(
        child: Column(
          children: [
            Image.asset('assets/payment_mean.png', height: 250),
            const Gutter(),
            const AppHeadlineText(text: "Choisissez un moyen de paiement"),

            const Gutter(),
            ...paymentState.availableProviders.map((provider) {
              final isSelected =
                  paymentState.selectedGateway == provider.shortcode;
              return Card(
                shape: !isSelected
                    ? null
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                elevation: 0.2,
                margin: const EdgeInsets.only(bottom: 20),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(provider.logo),
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text(provider.name),
                  subtitle: Text(provider.country.countryName),

                  onTap: () => _selectPaymentMethod(provider.shortcode),
                ),
              );
            }),
            const GutterLarge(),
            ElevatedButton(
              onPressed:
                  ref.read(paymentProvider).requireValue.selectedGateway == null
                  ? null
                  : widget.onTap,
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPaymentMethod(String gateway) =>
      ref.read(paymentProvider.notifier).selectGateway(gateway);
}
