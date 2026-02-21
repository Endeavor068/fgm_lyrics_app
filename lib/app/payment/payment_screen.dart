import 'package:confetti/confetti.dart';
import 'package:fgm_lyrics_app/app/data/payment_model.dart';
import 'package:fgm_lyrics_app/app/payment/payment_provider.dart';
import 'package:fgm_lyrics_app/core/utils/context_extension.dart';
import 'package:fgm_lyrics_app/core/utils/payunit_config.dart';
import 'package:fgm_lyrics_app/core/utils/phone_validation.dart';
import 'package:fgm_lyrics_app/core/widgets/app_default_spacing.dart';
import 'package:fgm_lyrics_app/core/widgets/app_headline_text.dart';
import 'package:fgm_lyrics_app/core/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/core/widgets/form_builder_phone_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gutter/flutter_gutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:phone_form_field/phone_form_field.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _phoneController = PhoneController(
    initialValue: const PhoneNumber(isoCode: IsoCode.CM, nsn: ""),
  );
  final _formKey = GlobalKey<FormBuilderState>();
  bool _hasShownSuccessDialog = false;

  @override
  Widget build(BuildContext context) {
    final paymentAsyncState = ref.watch(paymentProvider);

    // Listen for payment success
    ref.listen<AsyncValue<PaymentState>>(paymentProvider, (previous, next) {
      next.whenData((paymentState) {
        if (paymentState.statusResponse != null &&
            paymentState.statusResponse!.statusCode == 200 &&
            paymentState.isPaymentSuccessful &&
            !_hasShownSuccessDialog) {
          _hasShownSuccessDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSuccessDialog(context);
          });
        }
      });
    });

    return SliverToBoxAdapter(
      child: paymentAsyncState.when(
        data: (paymentState) => _buildPaymentForm(context, paymentState),
        loading: () => const AppDefaultSpacing(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => AppDefaultSpacing(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red.shade400),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(paymentProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, PaymentState paymentState) {
    final gateway = paymentState.selectedGateway;
    return AbsorbPointer(
      absorbing: paymentState.isLoading,
      child: AppDefaultSpacing(
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              spacing: 16,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image.asset('assets/logo_pay.png'),
                const AppHeadlineText(
                  text: "Remplissez les champs ci-dessous pour payer.",
                ),

                FormBuilderTextField(
                  name: 'name',
                  decoration: const InputDecoration(hintText: 'Nom & Prénom'),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  validator: FormBuilderValidators.minLength(
                    3,
                    errorText:
                        'Le nom ou prénom doit contenir au moins 3 caractères',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),

                FormBuilderPhoneField(
                  name: 'phone',
                  hintText: 'Numéro de téléphone',
                  phoneController: _phoneController,
                  isCountrySelectionEnabled: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (phone) => _validatePhone(phone, gateway),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Numéro de téléphone',
                  ),
                ),
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    hintText: 'Adresse mail (optionnel)',
                  ),
                  validator: _formKey.currentState?.value['email'] == null
                      ? null
                      : FormBuilderValidators.email(
                          errorText: 'Adresse mail invalide',
                        ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const GutterSmall(),

                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      showAdaptiveDialog(
                        builder: (context) => Dialog(
                          insetPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Confirmation de paiement',
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gutter(),
                                Text(
                                  'Vous serez débité de ${PayUnitConfig.appPrice} XAF sur votre compte Mobile Money. Êtes-vous sûr de vouloir continuer ?',
                                  style: context.textTheme.bodyLarge,
                                ),
                                const Gutter(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Annuler'),
                                    ),
                                    const Gutter(),
                                    TextButton(
                                      onPressed: () async {
                                        await _processPayment();
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text("Oui, continuer"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        context: context,
                      );
                    }
                  },
                  icon: paymentState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: AppProgressIndicator(),
                        )
                      : null,

                  label: paymentState.isLoading
                      ? const Text('Transaction en cours...')
                      : const Text('Confirmer et Payer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePhone(PhoneNumber? phone, String? gateway) {
    if (phone == null || phone.nsn.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }

    // Validate that it's a valid Cameroon phone number
    if (phone.isoCode != IsoCode.CM) {
      return 'Veuillez sélectionner un numéro Camerounais';
    }

    // Check if the phone number is valid for Cameroon
    if (!phone.isValid()) {
      return 'Numéro de téléphone invalide';
    }

    if (gateway == "CM_MTNMOMO") {
      if (!isMTN(phone.nsn)) {
        return "Ceci n'est pas un numéro MTN valide";
      }
    }

    if (gateway == "CM_ORANGE") {
      if (!isOrange(phone.nsn)) {
        return "Ceci n'est pas un numéro ORANGE valide";
      }
    }

    if (!isValidCameroonMobile(phone.nsn)) {
      return 'Uniquement les numéros MTN et Orange pour le moment';
    }

    return null;
  }

  Future<void> _processPayment() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    final formData = formState.value;
    final phoneNumber = _phoneController.value;
    final paymentState = ref.read(paymentProvider).hasValue
        ? ref.read(paymentProvider).requireValue
        : const PaymentState();

    final selectedGateway = paymentState.selectedGateway;
    if (selectedGateway == null) {
      // Initialize payment first if no gateway is selected
      final payment = Payment(
        name: formData['name'] as String,
        email: formData['email'] as String? ?? '',
        phone: phoneNumber.international,
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
      return;
    }

    final payment = Payment(
      name: formData['name'] ?? '',
      email: formData['email'] as String? ?? '',
      phone: phoneNumber.international,
      amount: PayUnitConfig.appPrice,
      currency: PayUnitConfig.currency,
    );

    await ref
        .read(paymentProvider.notifier)
        .processPayment(
          payment: payment,
          gateway: selectedGateway,
          returnUrl: PayUnitConfig.returnUrl,
          notifyUrl: PayUnitConfig.notifyUrl,
        );
  }

  void _showSuccessDialog(BuildContext context) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    confettiController.play();

    showDialog(
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
          child: ConfettiWidget(
            confettiController: confettiController,
            numberOfParticles: 150,
            gravity: 1,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 60,
                    color: Colors.green,
                  ),
                  const Gutter(),
                  Text(
                    'Paiement réussi !',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const GutterSmall(),
                  Text(
                    'Votre paiement a été effectué avec succès.',
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
                      // Dismiss the WoltModalSheet by popping the navigator
                      Navigator.of(dialogContext).pop();

                      Navigator.of(context).pop();
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
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
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
      ),
    ).then((_) {
      confettiController.dispose();
    });
  }
}
