/// Google Play / App Store in-app purchase configuration.
///
/// Create a matching non-consumable product in Google Play Console and
/// App Store Connect using [fullAccessProductId].
class IapConfig {
  IapConfig._();

  /// Non-consumable product that unlocks full app access.
  static const String fullAccessProductId = 'fgm_hymnals_full_access';

  static const Set<String> productIds = {fullAccessProductId};

  static const String purchaseStatusKey = 'iap_full_access_purchased';
}
