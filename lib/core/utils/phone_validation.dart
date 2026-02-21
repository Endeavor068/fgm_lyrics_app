/// General regex: All numbers must start with 6, be 9 digits total, no spaces/special chars
final RegExp generalMobileRegex = RegExp(r'^6\d{8}$');

/// MTN CM regex patterns:
/// - Starts with 6, then 8, followed by 7 more digits (e.g., 688684749)
/// - Starts with 6, then 7, followed by 7 more digits (e.g., 678684749)
/// - Starts with 6, then 5, followed by 0-4, then 6 more digits (e.g., 651684749)
final RegExp mtnRegex = RegExp(r'^6(8\d{7}|7\d{7}|5[0-4]\d{6})$');

/// Orange CM regex patterns:
/// - Starts with 6, then 9, followed by 7 more digits (e.g., 698684749)
/// - Starts with 6, then 5, followed by 5-9, then 6 more digits (e.g., 655684749)
final RegExp orangeRegex = RegExp(r'^6(9\d{7}|5[5-9]\d{6})$');

/// Combined regex for any valid Cameroonian mobile number (MTN or Orange)
final RegExp cameroonMobileRegex = RegExp(
  r'^6(8\d{7}|7\d{7}|5[0-4]\d{6}|9\d{7}|5[5-9]\d{6})$',
);

/// Validates if a string is a valid general mobile number format
/// (starts with 6, 9 digits total, no spaces/special characters)
bool isValidMobileFormat(String numero) {
  // Remove any spaces or special characters for validation
  final cleaned = numero.replaceAll(RegExp(r'[^\d]'), '');
  return generalMobileRegex.hasMatch(cleaned);
}

/// Validates if a number is an MTN Cameroon number
bool isMTN(String numero) {
  final cleaned = numero.replaceAll(RegExp(r'[^\d]'), '');
  return mtnRegex.hasMatch(cleaned);
}

/// Validates if a number is an Orange Cameroon number
bool isOrange(String numero) {
  final cleaned = numero.replaceAll(RegExp(r'[^\d]'), '');
  return orangeRegex.hasMatch(cleaned);
}

/// Validates if a number is a valid Cameroonian mobile number (MTN or Orange)
bool isValidCameroonMobile(String numero) {
  final cleaned = numero.replaceAll(RegExp(r'[^\d]'), '');
  return cameroonMobileRegex.hasMatch(cleaned);
}
