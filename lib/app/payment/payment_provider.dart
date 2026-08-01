import 'dart:async';

import 'package:fgm_lyrics_app/app/payment/iap_service.dart';
import 'package:fgm_lyrics_app/core/utils/iap_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for the in-app purchase flow.
class PurchaseState {
  final bool isStoreAvailable;
  final bool hasFullAccess;
  final bool isLoadingProduct;
  final bool isPurchasing;
  final bool isRestoring;
  final ProductDetails? product;
  final String? errorMessage;

  const PurchaseState({
    this.isStoreAvailable = false,
    this.hasFullAccess = false,
    this.isLoadingProduct = false,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.product,
    this.errorMessage,
  });

  bool get isBusy => isLoadingProduct || isPurchasing || isRestoring;

  String? get formattedPrice => product?.price;

  PurchaseState copyWith({
    bool? isStoreAvailable,
    bool? hasFullAccess,
    bool? isLoadingProduct,
    bool? isPurchasing,
    bool? isRestoring,
    ProductDetails? product,
    String? errorMessage,
    bool clearError = false,
    bool clearProduct = false,
  }) {
    return PurchaseState(
      isStoreAvailable: isStoreAvailable ?? this.isStoreAvailable,
      hasFullAccess: hasFullAccess ?? this.hasFullAccess,
      isLoadingProduct: isLoadingProduct ?? this.isLoadingProduct,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      product: clearProduct ? null : (product ?? this.product),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class PurchaseNotifier extends Notifier<PurchaseState> {
  IapService? _iapService;

  @override
  PurchaseState build() {
    ref.onDispose(() => _iapService?.dispose());
    unawaited(_initialize());
    return const PurchaseState(isLoadingProduct: true);
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _iapService = IapService(prefs);

    final available = await _iapService!.isStoreAvailable;
    final hasAccess = _iapService!.hasLocalPurchase;

    state = state.copyWith(
      isStoreAvailable: available,
      hasFullAccess: hasAccess,
      isLoadingProduct: available,
      clearError: true,
    );

    if (!available) {
      state = state.copyWith(isLoadingProduct: false);
      return;
    }

    _iapService!.listenPurchases(_handlePurchaseUpdate);

    try {
      final product = await _iapService!.fetchProduct();
      state = state.copyWith(
        product: product,
        isLoadingProduct: false,
        errorMessage: product == null ? 'product_not_found' : null,
        clearError: product != null,
      );
    } catch (e) {
      debugPrint('IAP product load failed: $e');
      state = state.copyWith(
        isLoadingProduct: false,
        errorMessage: 'product_load_failed',
      );
    }
  }

  Future<void> buyFullAccess() async {
    final service = _iapService;
    final product = state.product;
    if (service == null || product == null || state.isBusy) return;

    state = state.copyWith(isPurchasing: true, clearError: true);
    try {
      final started = await service.buy(product);
      if (!started) {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'purchase_start_failed',
        );
      }
    } catch (e) {
      debugPrint('IAP purchase failed: $e');
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'purchase_failed',
      );
    }
  }

  Future<void> restorePurchases() async {
    final service = _iapService;
    if (service == null || state.isBusy) return;

    state = state.copyWith(isRestoring: true, clearError: true);
    try {
      await service.restorePurchases();
    } catch (e) {
      debugPrint('IAP restore failed: $e');
      state = state.copyWith(
        isRestoring: false,
        errorMessage: 'restore_failed',
      );
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    final service = _iapService;
    if (service == null) return;

    if (purchase.productID != IapConfig.fullAccessProductId) return;

    switch (purchase.status) {
      case PurchaseStatus.pending:
        state = state.copyWith(isPurchasing: true, clearError: true);
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await service.markPurchased();
        if (purchase.pendingCompletePurchase) {
          await service.completePurchase(purchase);
        }
        state = state.copyWith(
          hasFullAccess: true,
          isPurchasing: false,
          isRestoring: false,
          clearError: true,
        );
      case PurchaseStatus.error:
        state = state.copyWith(
          isPurchasing: false,
          isRestoring: false,
          errorMessage: purchase.error?.message ?? 'purchase_failed',
        );
      case PurchaseStatus.canceled:
        state = state.copyWith(
          isPurchasing: false,
          isRestoring: false,
          clearError: true,
        );
    }
  }
}

final purchaseProvider = NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);

final hasFullAccessProvider = Provider<bool>((ref) {
  return ref.watch(purchaseProvider).hasFullAccess;
});
