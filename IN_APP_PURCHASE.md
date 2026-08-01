# In-App Purchase Integration

FGM Hymnals uses **Google Play Billing** (Android) and **App Store In-App Purchase** (iOS) via the official [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) Flutter plugin.

PayUnit / mobile-money integration has been removed.

## Product

| Field | Value |
|-------|-------|
| Product ID | `fgm_hymnals_full_access` |
| Type | Non-consumable (one-time unlock) |
| Config file | `lib/core/utils/iap_config.dart` |

Create the same product ID in:

1. **Google Play Console** → Monetize → Products → In-app products  
2. **App Store Connect** → Features → In-App Purchases (non-consumable)

## Code structure

| File | Role |
|------|------|
| `lib/core/utils/iap_config.dart` | Product IDs and local unlock key |
| `lib/app/payment/iap_service.dart` | Store API wrapper + SharedPreferences unlock flag |
| `lib/app/payment/payment_provider.dart` | Riverpod purchase state (`purchaseProvider`) |
| `lib/app/payment/pay_wall_screen.dart` | Purchase & restore UI |

## Purchase flow

1. App loads product details from the store.
2. User taps **Purchase** → platform billing sheet opens.
3. On success, purchase is completed and `iap_full_access_purchased` is saved locally.
4. **Restore purchases** re-validates prior non-consumable purchases with the store.

## Testing

### Android

- Upload a signed build to **Internal testing** track.
- Add license testers in Play Console.
- Use the same product ID configured as an in-app product.

### iOS

- Create the product in App Store Connect.
- Use a Sandbox Apple ID for testing.

## Play Console checklist

- [ ] Create non-consumable product `fgm_hymnals_full_access`
- [ ] Activate the product
- [x] Add privacy policy URL: https://sites.google.com/view/fgmn-hymnal-privacy-policy (also in `lib/core/utils/app_links.dart`)
- [ ] Declare **Financial info → Purchase history** in Data safety (processed by Google Play)

## Notes

- Unlock status is cached locally for fast UI; always offer **Restore purchases** on new devices.
- For stronger entitlement validation, add a backend receipt verification service later.
- Billing permission is merged automatically by the `in_app_purchase` plugin on Android.
