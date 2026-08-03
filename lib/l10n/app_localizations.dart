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
  /// **'FGM Hymnals'**
  String get appTitle;

  /// No description provided for @hymnalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hymnals'**
  String get hymnalsTitle;

  /// No description provided for @appBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL • MM'**
  String get appBrandTagline;

  /// No description provided for @detailBrandTitle.
  ///
  /// In en, this message translates to:
  /// **'FULL GOSPEL MISSION'**
  String get detailBrandTitle;

  /// No description provided for @detailBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hymnals • Official • MM'**
  String get detailBrandSubtitle;

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
  /// **'Search by number, title, lyrics or author'**
  String get searchHint;

  /// No description provided for @scrollToTopToSearch.
  ///
  /// In en, this message translates to:
  /// **'Back to top to search'**
  String get scrollToTopToSearch;

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
  /// **'FGM Hymnals • Official • MM'**
  String get splashOrganizationName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @hymnNoTranslation.
  ///
  /// In en, this message translates to:
  /// **'This hymn is not available in the other language yet.'**
  String get hymnNoTranslation;

  /// No description provided for @allHymnsOffline.
  ///
  /// In en, this message translates to:
  /// **'ALL HYMNS · OFFLINE'**
  String get allHymnsOffline;

  /// No description provided for @untitledHymn.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledHymn;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No hymns match your search.'**
  String get noSearchResults;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @remindersSection.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersSection;

  /// No description provided for @praiseRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Praise reminders'**
  String get praiseRemindersTitle;

  /// No description provided for @praiseRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One daily notification with an inspirational message to praise God.'**
  String get praiseRemindersSubtitle;

  /// No description provided for @audioNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get audioNowPlaying;

  /// No description provided for @audioReadyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to play'**
  String get audioReadyToPlay;

  /// No description provided for @audioTapToDownload.
  ///
  /// In en, this message translates to:
  /// **'Tap to download'**
  String get audioTapToDownload;

  /// No description provided for @audioDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get audioDownloading;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'How we collect, use, and protect your data.'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyPolicyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the privacy policy. Check your connection.'**
  String get privacyPolicyOpenFailed;

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
  /// **'Score'**
  String get sheetMusicTab;

  /// No description provided for @projectionTab.
  ///
  /// In en, this message translates to:
  /// **'Projection'**
  String get projectionTab;

  /// No description provided for @songHistoryTab.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get songHistoryTab;

  /// No description provided for @songHistoryComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Song history coming soon'**
  String get songHistoryComingSoonTitle;

  /// No description provided for @songHistoryComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'The story behind this hymn is not available yet. It will appear here once published.'**
  String get songHistoryComingSoonBody;

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

  /// No description provided for @chorusSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Chorus'**
  String get chorusSectionLabel;

  /// No description provided for @verseLabel.
  ///
  /// In en, this message translates to:
  /// **'Verse {number}'**
  String verseLabel(int number);

  /// No description provided for @projectionFullscreenHint.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen mode for video projector'**
  String get projectionFullscreenHint;

  /// No description provided for @projectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No lyrics available for projection.'**
  String get projectionEmpty;

  /// No description provided for @projectionSlideIndicator.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String projectionSlideIndicator(int current, int total);

  /// No description provided for @projectionTapToFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open fullscreen'**
  String get projectionTapToFullscreen;

  /// No description provided for @closeProjection.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeProjection;

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
  /// **'Unlock full access'**
  String get payWallTitle;

  /// No description provided for @payWallBody.
  ///
  /// In en, this message translates to:
  /// **'Purchase once through Google Play to unlock lifetime access to all hymns, audio, and sheet music.'**
  String get payWallBody;

  /// No description provided for @payWallPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get payWallPurchase;

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

  /// No description provided for @payWallRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get payWallRestore;

  /// No description provided for @payWallRestoreInProgress.
  ///
  /// In en, this message translates to:
  /// **'Restoring…'**
  String get payWallRestoreInProgress;

  /// No description provided for @payWallStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases are not available on this device.'**
  String get payWallStoreUnavailable;

  /// No description provided for @payWallProductLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load product information. Please try again later.'**
  String get payWallProductLoadError;

  /// No description provided for @payWallProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'The purchase product is not configured in the store yet.'**
  String get payWallProductNotFound;

  /// No description provided for @payWallPurchaseStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start the purchase. Please try again.'**
  String get payWallPurchaseStartFailed;

  /// No description provided for @payWallPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed.'**
  String get payWallPurchaseFailed;

  /// No description provided for @payWallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases. Please try again.'**
  String get payWallRestoreFailed;

  /// No description provided for @paymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing purchase…'**
  String get paymentProcessing;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Full access is now unlocked on this device.'**
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

  /// No description provided for @upgradeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get upgradeDialogTitle;

  /// No description provided for @upgradeDialogBody.
  ///
  /// In en, this message translates to:
  /// **'A newer version of {appName} is ready. Update now to keep enjoying the latest hymns and improvements.'**
  String upgradeDialogBody(String appName);

  /// No description provided for @upgradeDialogPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please update to continue.'**
  String get upgradeDialogPrompt;

  /// No description provided for @upgradeDialogUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get upgradeDialogUpdate;

  /// No description provided for @upgradeDialogReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'What’s new'**
  String get upgradeDialogReleaseNotes;
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
