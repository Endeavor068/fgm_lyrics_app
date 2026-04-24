import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FGM Hymns'**
  String get appTitle;

  /// No description provided for @hymnalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hymnals'**
  String get hymnalsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @couldNotLoadHymns.
  ///
  /// In en, this message translates to:
  /// **'Could not load hymns. Check connection or retry.'**
  String get couldNotLoadHymns;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search hymns…'**
  String get searchHint;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.\nAdd songs from the list to see them here.'**
  String get favoritesEmpty;

  /// No description provided for @splashOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Full Gospel Mission'**
  String get splashOrganizationName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @accentColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Accent color'**
  String get accentColorTitle;

  /// No description provided for @accentColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Primary color for buttons and highlights.'**
  String get accentColorSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @fontSizePt.
  ///
  /// In en, this message translates to:
  /// **'{size} pt'**
  String fontSizePt(String size);

  /// No description provided for @fontPreviewSample.
  ///
  /// In en, this message translates to:
  /// **'Amazing grace, how sweet the sound'**
  String get fontPreviewSample;

  /// No description provided for @fontFamily.
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// No description provided for @refreshHymnsTitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh hymns from server'**
  String get refreshHymnsTitle;

  /// No description provided for @refreshHymnsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fetch the latest hymn data and update local cache.'**
  String get refreshHymnsSubtitle;

  /// No description provided for @clearDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear downloaded data'**
  String get clearDataTitle;

  /// No description provided for @clearDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove all downloaded audio files and sheet music from this device.'**
  String get clearDataSubtitle;

  /// No description provided for @clearDataDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear downloaded data?'**
  String get clearDataDialogTitle;

  /// No description provided for @clearDataDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all downloaded audio files and sheet music from this device. Hymn text will not be affected.'**
  String get clearDataDialogMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @hymnsUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Hymns updated successfully.'**
  String get hymnsUpdatedSuccess;

  /// No description provided for @couldNotReachServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach server. Showing cached data.'**
  String get couldNotReachServer;

  /// No description provided for @downloadedDataCleared.
  ///
  /// In en, this message translates to:
  /// **'Downloaded data cleared.'**
  String get downloadedDataCleared;

  /// No description provided for @failedToClearData.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear some data. Please try again.'**
  String get failedToClearData;

  /// No description provided for @lyricsTab.
  ///
  /// In en, this message translates to:
  /// **'Lyrics'**
  String get lyricsTab;

  /// No description provided for @sheetMusicTab.
  ///
  /// In en, this message translates to:
  /// **'Sheet Music'**
  String get sheetMusicTab;

  /// No description provided for @composedLabel.
  ///
  /// In en, this message translates to:
  /// **'Composed'**
  String get composedLabel;

  /// No description provided for @keyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get keyLabel;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @chorusLabel.
  ///
  /// In en, this message translates to:
  /// **'Chorus:'**
  String get chorusLabel;

  /// No description provided for @pinchToZoom.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom'**
  String get pinchToZoom;

  /// No description provided for @pinchToZoomPdf.
  ///
  /// In en, this message translates to:
  /// **'Swipe sideways to turn pages · pinch to zoom'**
  String get pinchToZoomPdf;

  /// No description provided for @sheetMusicHeading.
  ///
  /// In en, this message translates to:
  /// **'Sheet Music'**
  String get sheetMusicHeading;

  /// No description provided for @partitionSavedLocal.
  ///
  /// In en, this message translates to:
  /// **'Partition saved locally. Tap to open in another app.'**
  String get partitionSavedLocal;

  /// No description provided for @partitionTapDownload.
  ///
  /// In en, this message translates to:
  /// **'Tap to download the partition.'**
  String get partitionTapDownload;

  /// No description provided for @partitionNone.
  ///
  /// In en, this message translates to:
  /// **'No sheet music available for this hymn.'**
  String get partitionNone;

  /// No description provided for @openExternally.
  ///
  /// In en, this message translates to:
  /// **'Open externally'**
  String get openExternally;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @couldNotDisplayImage.
  ///
  /// In en, this message translates to:
  /// **'Could not display this image.'**
  String get couldNotDisplayImage;

  /// No description provided for @couldNotDisplayPdf.
  ///
  /// In en, this message translates to:
  /// **'Could not display this PDF.\n{error}'**
  String couldNotDisplayPdf(String error);

  /// No description provided for @couldNotOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Could not open file: {error}'**
  String couldNotOpenFile(String error);

  /// No description provided for @shareSubjectSuffix.
  ///
  /// In en, this message translates to:
  /// **' - FGM Hymns'**
  String get shareSubjectSuffix;

  /// No description provided for @shareChorusPrefix.
  ///
  /// In en, this message translates to:
  /// **'*Chorus :*\n'**
  String get shareChorusPrefix;

  /// No description provided for @shareRefrainPrefix.
  ///
  /// In en, this message translates to:
  /// **'*Refrain :*\n'**
  String get shareRefrainPrefix;

  /// No description provided for @downloadFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please try again later.'**
  String get downloadFailedGeneric;

  /// No description provided for @corruptFileRedownloading.
  ///
  /// In en, this message translates to:
  /// **'Corrupt file removed. Re-downloading…'**
  String get corruptFileRedownloading;

  /// No description provided for @audioCouldNotPlay.
  ///
  /// In en, this message translates to:
  /// **'Audio file could not be played.'**
  String get audioCouldNotPlay;

  /// No description provided for @errorNoFileForHymn.
  ///
  /// In en, this message translates to:
  /// **'No file available for this hymn yet.'**
  String get errorNoFileForHymn;

  /// No description provided for @errorInvalidDownloadLink.
  ///
  /// In en, this message translates to:
  /// **'The download link is invalid. Please contact support.'**
  String get errorInvalidDownloadLink;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again when online.'**
  String get errorNoInternet;

  /// No description provided for @errorDownloadForbidden.
  ///
  /// In en, this message translates to:
  /// **'Download not allowed. The file is restricted.'**
  String get errorDownloadForbidden;

  /// No description provided for @errorFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found. It may have been moved or deleted.'**
  String get errorFileNotFound;

  /// No description provided for @errorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please try again later.'**
  String get errorDownloadFailed;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sacred\nEchoes'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore a vast collection of hymns and songs to enrich your spiritual journey.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeStartExploring.
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get welcomeStartExploring;

  /// No description provided for @welcomeLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get welcomeLogIn;

  /// No description provided for @labelAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author:'**
  String get labelAuthor;

  /// No description provided for @labelKey.
  ///
  /// In en, this message translates to:
  /// **'Key:'**
  String get labelKey;

  /// No description provided for @payWallTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy the app!'**
  String get payWallTitle;

  /// No description provided for @payWallBody.
  ///
  /// In en, this message translates to:
  /// **'It looks like you haven\'t purchased the app yet. Follow the steps to get lifetime access.'**
  String get payWallBody;

  /// No description provided for @payWallContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get payWallContinue;

  /// No description provided for @payWallLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get payWallLoading;

  /// No description provided for @payWallAlreadyPurchased.
  ///
  /// In en, this message translates to:
  /// **'Already purchased?'**
  String get payWallAlreadyPurchased;

  /// No description provided for @payWallClickHere.
  ///
  /// In en, this message translates to:
  /// **'Tap here'**
  String get payWallClickHere;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get paymentMethodTitle;

  /// No description provided for @paymentMethodContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paymentMethodContinue;

  /// No description provided for @paymentFormHeadline.
  ///
  /// In en, this message translates to:
  /// **'Fill in the fields below to pay.'**
  String get paymentFormHeadline;

  /// No description provided for @paymentHintName.
  ///
  /// In en, this message translates to:
  /// **'First & last name'**
  String get paymentHintName;

  /// No description provided for @paymentNameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get paymentNameMinLengthError;

  /// No description provided for @paymentHintPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get paymentHintPhone;

  /// No description provided for @paymentHintEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get paymentHintEmail;

  /// No description provided for @paymentEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get paymentEmailInvalid;

  /// No description provided for @paymentLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get paymentLoadingError;

  /// No description provided for @paymentRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paymentRetry;

  /// No description provided for @paymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmation'**
  String get paymentConfirmTitle;

  /// No description provided for @paymentConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You will be charged {price} XAF from your Mobile Money account. Do you want to continue?'**
  String paymentConfirmBody(String price);

  /// No description provided for @paymentCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get paymentCancel;

  /// No description provided for @paymentYesContinue.
  ///
  /// In en, this message translates to:
  /// **'Yes, continue'**
  String get paymentYesContinue;

  /// No description provided for @paymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing transaction…'**
  String get paymentProcessing;

  /// No description provided for @paymentConfirmPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm and pay'**
  String get paymentConfirmPay;

  /// No description provided for @paymentPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get paymentPhoneRequired;

  /// No description provided for @paymentCameroonOnly.
  ///
  /// In en, this message translates to:
  /// **'Please use a Cameroon number'**
  String get paymentCameroonOnly;

  /// No description provided for @paymentPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get paymentPhoneInvalid;

  /// No description provided for @paymentMtnInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid MTN number'**
  String get paymentMtnInvalid;

  /// No description provided for @paymentOrangeInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is not a valid Orange number'**
  String get paymentOrangeInvalid;

  /// No description provided for @paymentMtnOrangeOnly.
  ///
  /// In en, this message translates to:
  /// **'Only MTN and Orange numbers for now'**
  String get paymentMtnOrangeOnly;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your payment was completed successfully.'**
  String get paymentSuccessBody;

  /// No description provided for @paymentSuccessContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paymentSuccessContinue;

  /// No description provided for @pdfPageIndicator.
  ///
  /// In en, this message translates to:
  /// **'{page} / {total}'**
  String pdfPageIndicator(int page, int total);

  /// No description provided for @pdfPageLoading.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get pdfPageLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
