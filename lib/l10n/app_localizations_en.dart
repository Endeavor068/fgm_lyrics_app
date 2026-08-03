// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FGM Hymnals';

  @override
  String get hymnalsTitle => 'Hymnals';

  @override
  String get appBrandTagline => 'OFFICIAL • MM';

  @override
  String get detailBrandTitle => 'FULL GOSPEL MISSION';

  @override
  String get detailBrandSubtitle => 'Hymnals • Official • MM';

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
  String get searchHint => 'Search by number, title, lyrics or author';

  @override
  String get scrollToTopToSearch => 'Back to top to search';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty =>
      'No favorites yet.\nAdd songs from the list to see them here.';

  @override
  String get splashOrganizationName => 'FGM Hymnals • Official • MM';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get hymnNoTranslation =>
      'This hymn is not available in the other language yet.';

  @override
  String get allHymnsOffline => 'ALL HYMNS · OFFLINE';

  @override
  String get untitledHymn => 'Untitled';

  @override
  String get noSearchResults => 'No hymns match your search.';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get remindersSection => 'Reminders';

  @override
  String get praiseRemindersTitle => 'Praise reminders';

  @override
  String get praiseRemindersSubtitle =>
      'One daily notification with an inspirational message to praise God.';

  @override
  String get testNotificationTitle => 'Test notification';

  @override
  String get testNotificationSubtitle =>
      'Send a sample praise reminder now (temporary).';

  @override
  String get testNotificationSent => 'Test notification sent.';

  @override
  String get testNotificationPermissionDenied =>
      'Notification permission denied.';

  @override
  String get audioNowPlaying => 'Now playing';

  @override
  String get audioReadyToPlay => 'Ready to play';

  @override
  String get audioTapToDownload => 'Tap to download';

  @override
  String get audioDownloading => 'Downloading…';

  @override
  String get dataSection => 'Data';

  @override
  String get legalSection => 'Legal';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle =>
      'How we collect, use, and protect your data.';

  @override
  String get privacyPolicyOpenFailed =>
      'Could not open the privacy policy. Check your connection.';

  @override
  String get brightness => 'Brightness';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

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
  String get sheetMusicTab => 'Score';

  @override
  String get projectionTab => 'Projection';

  @override
  String get songHistoryTab => 'History';

  @override
  String get songHistoryComingSoonTitle => 'Song history coming soon';

  @override
  String get songHistoryComingSoonBody =>
      'The story behind this hymn is not available yet. It will appear here once published.';

  @override
  String get composedLabel => 'Composed';

  @override
  String get keyLabel => 'Key';

  @override
  String get notAvailable => 'N/A';

  @override
  String get chorusLabel => 'Chorus:';

  @override
  String get chorusSectionLabel => 'Chorus';

  @override
  String verseLabel(int number) {
    return 'Verse $number';
  }

  @override
  String get projectionFullscreenHint => 'Fullscreen mode for video projector';

  @override
  String get projectionEmpty => 'No lyrics available for projection.';

  @override
  String projectionSlideIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get projectionTapToFullscreen => 'Tap to open fullscreen';

  @override
  String get closeProjection => 'Close';

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
  String get payWallTitle => 'Unlock full access';

  @override
  String get payWallBody =>
      'Purchase once through Google Play to unlock lifetime access to all hymns, audio, and sheet music.';

  @override
  String get payWallPurchase => 'Purchase';

  @override
  String get payWallLoading => 'Loading…';

  @override
  String get payWallAlreadyPurchased => 'Already purchased?';

  @override
  String get payWallRestore => 'Restore purchases';

  @override
  String get payWallRestoreInProgress => 'Restoring…';

  @override
  String get payWallStoreUnavailable =>
      'In-app purchases are not available on this device.';

  @override
  String get payWallProductLoadError =>
      'Could not load product information. Please try again later.';

  @override
  String get payWallProductNotFound =>
      'The purchase product is not configured in the store yet.';

  @override
  String get payWallPurchaseStartFailed =>
      'Could not start the purchase. Please try again.';

  @override
  String get payWallPurchaseFailed => 'The purchase could not be completed.';

  @override
  String get payWallRestoreFailed =>
      'Could not restore purchases. Please try again.';

  @override
  String get paymentProcessing => 'Processing purchase…';

  @override
  String get paymentSuccessTitle => 'Purchase successful!';

  @override
  String get paymentSuccessBody =>
      'Thank you! Full access is now unlocked on this device.';

  @override
  String get paymentSuccessContinue => 'Continue';

  @override
  String pdfPageIndicator(int page, int total) {
    return '$page / $total';
  }

  @override
  String get pdfPageLoading => '…';

  @override
  String get upgradeDialogTitle => 'Update available';

  @override
  String upgradeDialogBody(String appName) {
    return 'A newer version of $appName is ready. Update now to keep enjoying the latest hymns and improvements.';
  }

  @override
  String get upgradeDialogPrompt => 'Please update to continue.';

  @override
  String get upgradeDialogUpdate => 'Update now';

  @override
  String get upgradeDialogReleaseNotes => 'What’s new';
}
