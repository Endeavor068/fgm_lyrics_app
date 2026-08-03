/// Inspirational praise & worship reminder copy (EN + FR).
class PraiseMessage {
  const PraiseMessage({
    required this.titleEn,
    required this.bodyEn,
    required this.titleFr,
    required this.bodyFr,
  });

  final String titleEn;
  final String bodyEn;
  final String titleFr;
  final String bodyFr;

  String titleFor(bool french) => french ? titleFr : titleEn;
  String bodyFor(bool french) => french ? bodyFr : bodyEn;
}

/// Varied reminders about the blessings of praising and worshiping God.
const List<PraiseMessage> kPraiseMessages = [
  PraiseMessage(
    titleEn: 'Start with praise',
    bodyEn:
        'Praise opens the day with peace. Lift your voice to God and let joy lead the way.',
    titleFr: 'Commencez par la louange',
    bodyFr:
        'La louange ouvre la journée dans la paix. Élevez votre voix vers Dieu et laissez la joie guider vos pas.',
  ),
  PraiseMessage(
    titleEn: 'Worship renews the heart',
    bodyEn:
        'Adoration softens worry and strengthens faith. Take a moment to worship Him today.',
    titleFr: 'L’adoration renouvelle le cœur',
    bodyFr:
        'L’adoration apaise les inquiétudes et fortifie la foi. Prenez un moment pour L’adorer aujourd’hui.',
  ),
  PraiseMessage(
    titleEn: 'God inhabits praise',
    bodyEn:
        'Where praise rises, God’s presence is near. Invite Him in with a song of thanksgiving.',
    titleFr: 'Dieu habite la louange',
    bodyFr:
        'Là où monte la louange, la présence de Dieu est proche. Invitez-Le par un chant de gratitude.',
  ),
  PraiseMessage(
    titleEn: 'Praise breaks heaviness',
    bodyEn:
        'When burdens feel heavy, praise lifts the spirit. Thank God—He is still faithful.',
    titleFr: 'La louange soulage le fardeau',
    bodyFr:
        'Quand le poids est lourd, la louange relève l’âme. Remerciez Dieu — Il reste fidèle.',
  ),
  PraiseMessage(
    titleEn: 'A grateful heart sings',
    bodyEn:
        'Gratitude turns ordinary moments into worship. Count His blessings and praise His name.',
    titleFr: 'Un cœur reconnaissant chante',
    bodyFr:
        'La gratitude transforme l’ordinaire en adoration. Comptez Ses bienfaits et louez Son nom.',
  ),
  PraiseMessage(
    titleEn: 'Evening thanksgiving',
    bodyEn:
        'Close the day in worship. Thank God for His mercy that carried you through.',
    titleFr: 'Action de grâce du soir',
    bodyFr:
        'Terminez la journée dans l’adoration. Remerciez Dieu pour Sa miséricorde qui vous a soutenu.',
  ),
  PraiseMessage(
    titleEn: 'Praise brings clarity',
    bodyEn:
        'Worship realigns the mind with God’s truth. Pause, praise, and find fresh perspective.',
    titleFr: 'La louange apporte la clarté',
    bodyFr:
        'L’adoration réoriente l’esprit vers la vérité de Dieu. Pausez, louez, et retrouvez une vision nouvelle.',
  ),
  PraiseMessage(
    titleEn: 'Joy is found in Him',
    bodyEn:
        'The joy of the Lord is your strength. Praise unlocks joy that circumstances cannot steal.',
    titleFr: 'La joie se trouve en Lui',
    bodyFr:
        'La joie du Seigneur est votre force. La louange libère une joie que les circonstances ne peuvent voler.',
  ),
  PraiseMessage(
    titleEn: 'Worship is a weapon',
    bodyEn:
        'Praise pushes back fear and doubt. Stand firm and exalt the name of Jesus.',
    titleFr: 'L’adoration est une arme',
    bodyFr:
        'La louange repousse la peur et le doute. Tenez ferme et exaltez le nom de Jésus.',
  ),
  PraiseMessage(
    titleEn: 'Draw near with praise',
    bodyEn:
        'Enter His gates with thanksgiving. A few honest words of praise open heaven’s door.',
    titleFr: 'Approchez-vous par la louange',
    bodyFr:
        'Entrez dans Ses portes avec des actions de grâce. Quelques paroles sincères ouvrent la porte du ciel.',
  ),
  PraiseMessage(
    titleEn: 'He is worthy',
    bodyEn:
        'Not for what we feel, but for who He is—God deserves our praise every morning and night.',
    titleFr: 'Il est digne',
    bodyFr:
        'Non pour ce que nous ressentons, mais pour qui Il est — Dieu mérite notre louange matin et soir.',
  ),
  PraiseMessage(
    titleEn: 'Praise heals the soul',
    bodyEn:
        'Worship soothes anxious thoughts. Sing to the Lord and let His peace settle over you.',
    titleFr: 'La louange guérit l’âme',
    bodyFr:
        'L’adoration apaise les pensées anxieuses. Chantez au Seigneur et laissez Sa paix vous envelopper.',
  ),
  PraiseMessage(
    titleEn: 'Faith grows in worship',
    bodyEn:
        'As you praise, faith rises. Remember His past faithfulness and trust Him again today.',
    titleFr: 'La foi grandit dans l’adoration',
    bodyFr:
        'En louant, la foi grandit. Souvenez-vous de Sa fidélité passée et faites-Lui encore confiance aujourd’hui.',
  ),
  PraiseMessage(
    titleEn: 'Make room for God',
    bodyEn:
        'A short moment of praise can change the atmosphere of your home and heart.',
    titleFr: 'Faites de la place à Dieu',
    bodyFr:
        'Un court moment de louange peut transformer l’atmosphère de votre maison et de votre cœur.',
  ),
  PraiseMessage(
    titleEn: 'Morning mercy',
    bodyEn:
        'His mercies are new every morning. Greet the day with thanksgiving and song.',
    titleFr: 'Miséricorde du matin',
    bodyFr:
        'Ses compassions se renouvellent chaque matin. Accueillez le jour avec gratitude et chant.',
  ),
  PraiseMessage(
    titleEn: 'Praise unites us',
    bodyEn:
        'When God’s people praise, hearts are knit together. Join the song of the redeemed.',
    titleFr: 'La louange nous unit',
    bodyFr:
        'Quand le peuple de Dieu loue, les cœurs se rassemblent. Joignez-vous au chant des rachetés.',
  ),
  PraiseMessage(
    titleEn: 'From worry to worship',
    bodyEn:
        'Trade anxious thoughts for a hymn of trust. God is greater than what you face.',
    titleFr: 'De l’inquiétude à l’adoration',
    bodyFr:
        'Échangez vos soucis contre un cantique de confiance. Dieu est plus grand que ce que vous traversez.',
  ),
  PraiseMessage(
    titleEn: 'Bless the Lord always',
    bodyEn:
        'In every season, bless His name. Praise is a choice that invites His presence.',
    titleFr: 'Bénissez le Seigneur toujours',
    bodyFr:
        'En toute saison, bénissez Son nom. La louange est un choix qui invite Sa présence.',
  ),
  PraiseMessage(
    titleEn: 'Worship before sleep',
    bodyEn:
        'End the day with praise and rest in His care. He watches over you through the night.',
    titleFr: 'Adorez avant de dormir',
    bodyFr:
        'Terminez la journée par la louange et reposez-vous en Sa garde. Il veille sur vous cette nuit.',
  ),
  PraiseMessage(
    titleEn: 'Open your hymnal',
    bodyEn:
        'A familiar hymn can awaken fresh love for God. Open the app and lift His name high.',
    titleFr: 'Ouvrez votre recueil',
    bodyFr:
        'Un cantique familier peut ranimer l’amour pour Dieu. Ouvrez l’application et élevez Son nom.',
  ),
  PraiseMessage(
    titleEn: 'Praise invites breakthrough',
    bodyEn:
        'Walls fall when God’s people worship. Keep praising—He is working even now.',
    titleFr: 'La louange ouvre des brèches',
    bodyFr:
        'Les murs tombent quand le peuple de Dieu adore. Continuez de louer — Il agit même maintenant.',
  ),
  PraiseMessage(
    titleEn: 'Give Him glory',
    bodyEn:
        'Everything good comes from Him. Pause and give glory to the Giver of every gift.',
    titleFr: 'Rendez-Lui gloire',
    bodyFr:
        'Tout bien vient de Lui. Pausez et rendez gloire au Donateur de tout don parfait.',
  ),
  PraiseMessage(
    titleEn: 'Let heaven hear you',
    bodyEn:
        'Your praise is not small. Heaven listens when a thankful heart sings to God.',
    titleFr: 'Que le ciel vous entende',
    bodyFr:
        'Votre louange n’est pas petite. Le ciel écoute quand un cœur reconnaissant chante à Dieu.',
  ),
  PraiseMessage(
    titleEn: 'Stay near through song',
    bodyEn:
        'Worship keeps your heart close to God through busy days. Sing, even softly.',
    titleFr: 'Restez près par le chant',
    bodyFr:
        'L’adoration garde votre cœur près de Dieu au milieu des journées chargées. Chantez, même doucement.',
  ),
];
