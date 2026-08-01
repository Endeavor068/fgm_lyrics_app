import 'dart:async';

import 'package:fgm_lyrics_app/core/utils/iap_config.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps the platform in-app purchase APIs and local unlock persistence.
class IapService {
  IapService(this._prefs);

  final SharedPreferences _prefs;
  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  Future<bool> get isStoreAvailable => _iap.isAvailable();

  bool get hasLocalPurchase =>
      _prefs.getBool(IapConfig.purchaseStatusKey) ?? false;

  Future<void> markPurchased() async {
    await _prefs.setBool(IapConfig.purchaseStatusKey, true);
  }

  Future<void> clearLocalPurchase() async {
    await _prefs.remove(IapConfig.purchaseStatusKey);
  }

  Future<ProductDetails?> fetchProduct() async {
    final response = await _iap.queryProductDetails(IapConfig.productIds);
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  Future<bool> buy(ProductDetails product) {
    final purchaseParam = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  void listenPurchases(void Function(PurchaseDetails purchase) onUpdate) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        onUpdate(purchase);
      }
    });
  }

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);

  void dispose() => _subscription?.cancel();
}
