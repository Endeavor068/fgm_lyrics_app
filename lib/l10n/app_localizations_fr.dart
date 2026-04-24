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
  String get settingsTooltip => 'Réglages';

  @override
  String get couldNotLoadHymns =>
      'Impossible de charger les cantiques. Vérifiez la connexion ou réessayez.';

  @override
  String get retry => 'Réessayer';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchHint => 'Rechercher des cantiques…';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmpty =>
      'Aucun favori pour le moment.\nAjoutez des cantiques depuis la liste pour les voir ici.';

  @override
  String get splashOrganizationName => 'Full Gospel Mission';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get dataSection => 'Données';

  @override
  String get brightness => 'Luminosité';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get accentColorTitle => 'Couleur d\'accent';

  @override
  String get accentColorSubtitle =>
      'Couleur principale des boutons et des surbrillances.';

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
  String get composedLabel => 'Composé';

  @override
  String get keyLabel => 'Tonalité';

  @override
  String get notAvailable => 'N/D';

  @override
  String get chorusLabel => 'Refrain :';

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
  String get payWallTitle => 'Acheter l\'application !';

  @override
  String get payWallBody =>
      'Il semble que vous n\'ayez pas encore acheté l\'application. Veuillez suivre les étapes pour bénéficier d\'un accès à vie.';

  @override
  String get payWallContinue => 'Continuer';

  @override
  String get payWallLoading => 'Chargement…';

  @override
  String get payWallAlreadyPurchased => 'Vous aviez déjà acheté ?';

  @override
  String get payWallClickHere => 'Cliquez ici !';

  @override
  String get paymentMethodTitle => 'Choisissez un moyen de paiement';

  @override
  String get paymentMethodContinue => 'Continuer';

  @override
  String get paymentFormHeadline =>
      'Remplissez les champs ci-dessous pour payer.';

  @override
  String get paymentHintName => 'Nom & Prénom';

  @override
  String get paymentNameMinLengthError =>
      'Le nom ou prénom doit contenir au moins 3 caractères';

  @override
  String get paymentHintPhone => 'Numéro de téléphone';

  @override
  String get paymentHintEmail => 'Adresse mail (optionnel)';

  @override
  String get paymentEmailInvalid => 'Adresse mail invalide';

  @override
  String get paymentLoadingError => 'Erreur de chargement';

  @override
  String get paymentRetry => 'Réessayer';

  @override
  String get paymentConfirmTitle => 'Confirmation de paiement';

  @override
  String paymentConfirmBody(String price) {
    return 'Vous serez débité de $price XAF sur votre compte Mobile Money. Êtes-vous sûr de vouloir continuer ?';
  }

  @override
  String get paymentCancel => 'Annuler';

  @override
  String get paymentYesContinue => 'Oui, continuer';

  @override
  String get paymentProcessing => 'Transaction en cours…';

  @override
  String get paymentConfirmPay => 'Confirmer et Payer';

  @override
  String get paymentPhoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get paymentCameroonOnly =>
      'Veuillez sélectionner un numéro camerounais';

  @override
  String get paymentPhoneInvalid => 'Numéro de téléphone invalide';

  @override
  String get paymentMtnInvalid => 'Ceci n\'est pas un numéro MTN valide';

  @override
  String get paymentOrangeInvalid => 'Ceci n\'est pas un numéro ORANGE valide';

  @override
  String get paymentMtnOrangeOnly =>
      'Uniquement les numéros MTN et Orange pour le moment';

  @override
  String get paymentSuccessTitle => 'Paiement réussi !';

  @override
  String get paymentSuccessBody => 'Votre paiement a été effectué avec succès.';

  @override
  String get paymentSuccessContinue => 'Continuer';

  @override
  String pdfPageIndicator(int page, int total) {
    return '$page / $total';
  }

  @override
  String get pdfPageLoading => '…';
}
