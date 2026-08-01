// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cantiques FGM';

  @override
  String get hymnalsTitle => 'Cantiques';

  @override
  String get appBrandTagline => 'OFFICIEL · FGM';

  @override
  String get settingsTooltip => 'Réglages';

  @override
  String get couldNotLoadHymns =>
      'Impossible de charger les cantiques. Vérifiez la connexion ou réessayez.';

  @override
  String get retry => 'Réessayer';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchHint => 'Rechercher titre ou paroles…';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmpty =>
      'Aucun favori pour le moment.\nAjoutez des cantiques depuis la liste pour les voir ici.';

  @override
  String get splashOrganizationName => 'MPE Cantiques - Officiel - MM';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get navHome => 'Accueil';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get hymnNoTranslation =>
      'Ce cantique n’a pas encore de version dans l’autre langue.';

  @override
  String get allHymnsOffline => 'TOUS LES CANTIQUES · HORS LIGNE';

  @override
  String get untitledHymn => 'Sans titre';

  @override
  String get noSearchResults =>
      'Aucun cantique ne correspond à votre recherche.';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get dataSection => 'Données';

  @override
  String get legalSection => 'Mentions légales';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle =>
      'Comment nous collectons, utilisons et protégeons vos données.';

  @override
  String get privacyPolicyOpenFailed =>
      'Impossible d\'ouvrir la politique de confidentialité. Vérifiez votre connexion.';

  @override
  String get brightness => 'Luminosité';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get fontSize => 'Taille du texte';

  @override
  String fontSizePt(String size) {
    return '$size pt';
  }

  @override
  String get fontPreviewSample => 'Quel sauveur merveilleux, Jésus mon roi';

  @override
  String get fontFamily => 'Police';

  @override
  String get refreshHymnsTitle => 'Actualiser les cantiques depuis le serveur';

  @override
  String get refreshHymnsSubtitle =>
      'Récupérer les dernières données et mettre à jour le cache local.';

  @override
  String get clearDataTitle => 'Effacer les données téléchargées';

  @override
  String get clearDataSubtitle =>
      'Supprimer tous les fichiers audio et partitions téléchargés sur cet appareil.';

  @override
  String get clearDataDialogTitle => 'Effacer les données téléchargées ?';

  @override
  String get clearDataDialogMessage =>
      'Cela supprimera tous les fichiers audio et partitions téléchargés sur cet appareil. Le texte des cantiques ne sera pas affecté.';

  @override
  String get clear => 'Effacer';

  @override
  String get cancel => 'Annuler';

  @override
  String get hymnsUpdatedSuccess => 'Cantiques mis à jour avec succès.';

  @override
  String get couldNotReachServer =>
      'Impossible de joindre le serveur. Affichage des données en cache.';

  @override
  String get downloadedDataCleared => 'Données téléchargées effacées.';

  @override
  String get failedToClearData => 'Échec de l\'effacement. Veuillez réessayer.';

  @override
  String get lyricsTab => 'Paroles';

  @override
  String get sheetMusicTab => 'Partition';

  @override
  String get projectionTab => 'Projection';

  @override
  String get composedLabel => 'Composé';

  @override
  String get keyLabel => 'Tonalité';

  @override
  String get notAvailable => 'N/D';

  @override
  String get chorusLabel => 'Refrain :';

  @override
  String get chorusSectionLabel => 'Refrain';

  @override
  String verseLabel(int number) {
    return 'Couplet $number';
  }

  @override
  String get projectionFullscreenHint =>
      'Mode plein écran pour vidéoprojecteur';

  @override
  String get projectionEmpty => 'Aucune parole disponible pour la projection.';

  @override
  String projectionSlideIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get projectionTapToFullscreen => 'Toucher pour le plein écran';

  @override
  String get closeProjection => 'Fermer';

  @override
  String get pinchToZoom => 'Pincer pour zoomer';

  @override
  String get pinchToZoomPdf =>
      'Balayez sur le côté pour changer de page · pincer pour zoomer';

  @override
  String get sheetMusicHeading => 'Partition';

  @override
  String get partitionSavedLocal =>
      'Partition enregistrée localement. Touchez pour ouvrir dans une autre application.';

  @override
  String get partitionTapDownload => 'Touchez pour télécharger la partition.';

  @override
  String get partitionNone => 'Aucune partition disponible pour ce cantique.';

  @override
  String get openExternally => 'Ouvrir en externe';

  @override
  String get download => 'Télécharger';

  @override
  String get previousPage => 'Page précédente';

  @override
  String get nextPage => 'Page suivante';

  @override
  String get couldNotDisplayImage => 'Impossible d\'afficher cette image.';

  @override
  String couldNotDisplayPdf(String error) {
    return 'Impossible d\'afficher ce PDF.\n$error';
  }

  @override
  String couldNotOpenFile(String error) {
    return 'Impossible d\'ouvrir le fichier : $error';
  }

  @override
  String get shareSubjectSuffix => ' - Cantiques FGM';

  @override
  String get shareChorusPrefix => '*Chœur :*\n';

  @override
  String get shareRefrainPrefix => '*Refrain :*\n';

  @override
  String get downloadFailedGeneric =>
      'Échec du téléchargement. Veuillez réessayer plus tard.';

  @override
  String get corruptFileRedownloading =>
      'Fichier corrompu supprimé. Nouveau téléchargement…';

  @override
  String get audioCouldNotPlay => 'Impossible de lire le fichier audio.';

  @override
  String get errorNoFileForHymn =>
      'Aucun fichier disponible pour ce cantique pour le moment.';

  @override
  String get errorInvalidDownloadLink =>
      'Le lien de téléchargement est invalide. Contactez le support.';

  @override
  String get errorNoInternet =>
      'Pas de connexion Internet. Réessayez lorsque vous serez en ligne.';

  @override
  String get errorDownloadForbidden =>
      'Téléchargement non autorisé. Le fichier est restreint.';

  @override
  String get errorFileNotFound =>
      'Fichier introuvable. Il a peut-être été déplacé ou supprimé.';

  @override
  String get errorDownloadFailed =>
      'Échec du téléchargement. Veuillez réessayer plus tard.';

  @override
  String get welcomeTitle => 'Bienvenue à Sacred\nEchoes';

  @override
  String get welcomeSubtitle =>
      'Explorez une vaste collection de cantiques et chants pour enrichir votre cheminement spirituel.';

  @override
  String get welcomeStartExploring => 'Commencer';

  @override
  String get welcomeLogIn => 'Connexion';

  @override
  String get labelAuthor => 'Auteur :';

  @override
  String get labelKey => 'Tonalité :';

  @override
  String get payWallTitle => 'Débloquer l\'accès complet';

  @override
  String get payWallBody =>
      'Achetez une seule fois via Google Play pour débloquer l\'accès à vie à tous les cantiques, audios et partitions.';

  @override
  String get payWallPurchase => 'Acheter';

  @override
  String get payWallLoading => 'Chargement…';

  @override
  String get payWallAlreadyPurchased => 'Vous aviez déjà acheté ?';

  @override
  String get payWallRestore => 'Restaurer les achats';

  @override
  String get payWallRestoreInProgress => 'Restauration…';

  @override
  String get payWallStoreUnavailable =>
      'Les achats intégrés ne sont pas disponibles sur cet appareil.';

  @override
  String get payWallProductLoadError =>
      'Impossible de charger les informations du produit. Réessayez plus tard.';

  @override
  String get payWallProductNotFound =>
      'Le produit d\'achat n\'est pas encore configuré dans la boutique.';

  @override
  String get payWallPurchaseStartFailed =>
      'Impossible de démarrer l\'achat. Veuillez réessayer.';

  @override
  String get payWallPurchaseFailed => 'L\'achat n\'a pas pu être finalisé.';

  @override
  String get payWallRestoreFailed =>
      'Impossible de restaurer les achats. Veuillez réessayer.';

  @override
  String get paymentProcessing => 'Achat en cours…';

  @override
  String get paymentSuccessTitle => 'Achat réussi !';

  @override
  String get paymentSuccessBody =>
      'Merci ! L\'accès complet est maintenant débloqué sur cet appareil.';

  @override
  String get paymentSuccessContinue => 'Continuer';

  @override
  String pdfPageIndicator(int page, int total) {
    return '$page / $total';
  }

  @override
  String get pdfPageLoading => '…';
}
