// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FGM Hymns';

  @override
  String get hymnalsTitle => 'Hymnals';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get couldNotLoadHymns =>
      'Could not load hymns. Check connection or retry.';

  @override
  String get retry => 'Retry';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search hymns…';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty =>
      'No favorites yet.\nAdd songs from the list to see them here.';

  @override
  String get splashOrganizationName => 'Full Gospel Mission';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get dataSection => 'Data';

  @override
  String get brightness => 'Brightness';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get accentColorTitle => 'Accent color';

  @override
  String get accentColorSubtitle => 'Primary color for buttons and highlights.';

  @override
  String get fontSize => 'Font Size';

  @override
  String fontSizePt(String size) {
    return '$size pt';
  }

  @override
  String get fontPreviewSample => 'Amazing grace, how sweet the sound';

  @override
  String get fontFamily => 'Font Family';

  @override
  String get refreshHymnsTitle => 'Refresh hymns from server';

  @override
  String get refreshHymnsSubtitle =>
      'Fetch the latest hymn data and update local cache.';

  @override
  String get clearDataTitle => 'Clear downloaded data';

  @override
  String get clearDataSubtitle =>
      'Remove all downloaded audio files and sheet music from this device.';

  @override
  String get clearDataDialogTitle => 'Clear downloaded data?';

  @override
  String get clearDataDialogMessage =>
      'This will delete all downloaded audio files and sheet music from this device. Hymn text will not be affected.';

  @override
  String get clear => 'Clear';

  @override
  String get cancel => 'Cancel';

  @override
  String get hymnsUpdatedSuccess => 'Hymns updated successfully.';

  @override
  String get couldNotReachServer =>
      'Could not reach server. Showing cached data.';

  @override
  String get downloadedDataCleared => 'Downloaded data cleared.';

  @override
  String get failedToClearData =>
      'Failed to clear some data. Please try again.';

  @override
  String get lyricsTab => 'Lyrics';

  @override
  String get sheetMusicTab => 'Sheet Music';

  @override
  String get composedLabel => 'Composed';

  @override
  String get keyLabel => 'Key';

  @override
  String get notAvailable => 'N/A';

  @override
  String get chorusLabel => 'Chorus:';

  @override
  String get pinchToZoom => 'Pinch to zoom';

  @override
  String get pinchToZoomPdf => 'Swipe sideways to turn pages · pinch to zoom';

  @override
  String get sheetMusicHeading => 'Sheet Music';

  @override
  String get partitionSavedLocal =>
      'Partition saved locally. Tap to open in another app.';

  @override
  String get partitionTapDownload => 'Tap to download the partition.';

  @override
  String get partitionNone => 'No sheet music available for this hymn.';

  @override
  String get openExternally => 'Open externally';

  @override
  String get download => 'Download';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get couldNotDisplayImage => 'Could not display this image.';

  @override
  String couldNotDisplayPdf(String error) {
    return 'Could not display this PDF.\n$error';
  }

  @override
  String couldNotOpenFile(String error) {
    return 'Could not open file: $error';
  }

  @override
  String get shareSubjectSuffix => ' - FGM Hymns';

  @override
  String get shareChorusPrefix => '*Chorus :*\n';

  @override
  String get shareRefrainPrefix => '*Refrain :*\n';

  @override
  String get downloadFailedGeneric =>
      'Download failed. Please try again later.';

  @override
  String get corruptFileRedownloading =>
      'Corrupt file removed. Re-downloading…';

  @override
  String get audioCouldNotPlay => 'Audio file could not be played.';

  @override
  String get errorNoFileForHymn => 'No file available for this hymn yet.';

  @override
  String get errorInvalidDownloadLink =>
      'The download link is invalid. Please contact support.';

  @override
  String get errorNoInternet =>
      'No internet connection. Please try again when online.';

  @override
  String get errorDownloadForbidden =>
      'Download not allowed. The file is restricted.';

  @override
  String get errorFileNotFound =>
      'File not found. It may have been moved or deleted.';

  @override
  String get errorDownloadFailed => 'Download failed. Please try again later.';

  @override
  String get welcomeTitle => 'Welcome to Sacred\nEchoes';

  @override
  String get welcomeSubtitle =>
      'Explore a vast collection of hymns and songs to enrich your spiritual journey.';

  @override
  String get welcomeStartExploring => 'Start Exploring';

  @override
  String get welcomeLogIn => 'Log In';

  @override
  String get labelAuthor => 'Author:';

  @override
  String get labelKey => 'Key:';

  @override
  String get payWallTitle => 'Buy the app!';

  @override
  String get payWallBody =>
      'It looks like you haven\'t purchased the app yet. Follow the steps to get lifetime access.';

  @override
  String get payWallContinue => 'Continue';

  @override
  String get payWallLoading => 'Loading…';

  @override
  String get payWallAlreadyPurchased => 'Already purchased?';

  @override
  String get payWallClickHere => 'Tap here';

  @override
  String get paymentMethodTitle => 'Choose a payment method';

  @override
  String get paymentMethodContinue => 'Continue';

  @override
  String get paymentFormHeadline => 'Fill in the fields below to pay.';

  @override
  String get paymentHintName => 'First & last name';

  @override
  String get paymentNameMinLengthError => 'Name must be at least 3 characters';

  @override
  String get paymentHintPhone => 'Phone number';

  @override
  String get paymentHintEmail => 'Email (optional)';

  @override
  String get paymentEmailInvalid => 'Invalid email address';

  @override
  String get paymentLoadingError => 'Loading error';

  @override
  String get paymentRetry => 'Retry';

  @override
  String get paymentConfirmTitle => 'Payment confirmation';

  @override
  String paymentConfirmBody(String price) {
    return 'You will be charged $price XAF from your Mobile Money account. Do you want to continue?';
  }

  @override
  String get paymentCancel => 'Cancel';

  @override
  String get paymentYesContinue => 'Yes, continue';

  @override
  String get paymentProcessing => 'Processing transaction…';

  @override
  String get paymentConfirmPay => 'Confirm and pay';

  @override
  String get paymentPhoneRequired => 'Phone number is required';

  @override
  String get paymentCameroonOnly => 'Please use a Cameroon number';

  @override
  String get paymentPhoneInvalid => 'Invalid phone number';

  @override
  String get paymentMtnInvalid => 'This is not a valid MTN number';

  @override
  String get paymentOrangeInvalid => 'This is not a valid Orange number';

  @override
  String get paymentMtnOrangeOnly => 'Only MTN and Orange numbers for now';

  @override
  String get paymentSuccessTitle => 'Payment successful!';

  @override
  String get paymentSuccessBody => 'Your payment was completed successfully.';

  @override
  String get paymentSuccessContinue => 'Continue';

  @override
  String pdfPageIndicator(int page, int total) {
    return '$page / $total';
  }

  @override
  String get pdfPageLoading => '…';
}
