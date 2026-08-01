# Privacy Policy — FGM Hymnals - Official - MM

**Effective date:** July 17, 2026  
**Last updated:** August 1, 2026

---

## 1. Introduction

Full Gospel Mission (“**we**,” “**us**,” or “**our**”) operates **FGM Hymnals - Official - MM** (the “**App**”), a mobile application that lets you browse hymn lyrics, sheet music, and audio recordings published by Full Gospel Mission.

This Privacy Policy explains what information is processed when you use the App, how we use it, who we share it with, and what choices you have. It applies to the App on Android, iOS, and other platforms where the App is distributed.

By using the App, you agree to the practices described in this policy. If you do not agree, please do not use the App.

---

## 2. Who Is Responsible for Your Data

**Data controller:**  
Full Gospel Mission  
Bepanda Casmando  
Bepanda 00000  
Douala, Cameroon

**Privacy contact:**  
Email: appsindustry068@gmail.com

For users in the European Economic Area (EEA), United Kingdom, or Switzerland, Full Gospel Mission is the controller of personal data described in this policy.

---

## 3. Summary

| Topic | What the App does |
|-------|-------------------|
| User accounts | **No.** The App does not require registration or login. |
| Advertising | **No.** We do not show ads and do not use advertising identifiers. |
| Analytics | **No dedicated analytics SDK.** We do not use Google Analytics or similar in-app analytics tools. |
| Device identifiers | **Via Firebase only** — installation/device IDs may be processed by Google to operate Firebase services. |
| Location | **No.** We do not collect GPS or precise location. |
| Camera / microphone / contacts | **No.** These are not accessed. |
| Favorites & settings | Stored **locally on your device** only. |
| Hymn catalog | Downloaded from **Google Firebase (Firestore)**. |
| Audio & sheet music | Downloaded from **Firebase Storage** when you request them. |
| Sharing lyrics | Uses your device’s **system share sheet**; we do not receive shared content. |
| Payments (if enabled) | Processed by **Google Play Billing** (Android) or **Apple In-App Purchase** (iOS); we do not collect or store payment card details. |

---

## 4. Information We Collect

We collect only the information needed to provide App features. We do **not** sell your personal information.

### 4.1 Information stored locally on your device

The following data stays on your device unless you delete the App or clear it through App settings:

| Data | Purpose | Storage |
|------|---------|---------|
| **Favorite hymns** | Save hymns you mark as favorites | On your device only |
| **Theme preference** | Light, dark, or system theme | On your device only |
| **Accent color** | UI color choice | On your device only |
| **Font size & font family** | Hymn text display preferences | On your device only |
| **Cached hymn catalog** | Offline access to hymn metadata | On your device only |
| **Downloaded audio files** | Play hymns offline | On your device only |
| **Downloaded sheet music** | View partitions offline | On your device only |
| **Purchase unlock status** | Remember that full access was purchased | On your device only |

This data is **not uploaded to our servers** and is **not linked to your identity** because the App has no user accounts.

You can delete downloaded audio, partitions, and the hymn cache at any time in **Settings → Clear downloaded data**. Favorites and appearance settings are removed when you uninstall the App or clear app data at the OS level.

### 4.2 Information processed when you use App features

| Activity | Data involved | Sent to us? |
|----------|---------------|-------------|
| **Browse / search hymns** | Search terms are processed in memory on your device only | No |
| **Refresh hymn catalog** | App requests hymn documents from Firestore | Read-only; no user identifier attached by our code |
| **Download audio or sheet music** | HTTP request to Firebase Storage URL for the selected hymn | Request goes to Google/Firebase; we do not log your identity |
| **Share a hymn** | Hymn title, number, and lyrics text you choose to share | No — sharing goes directly through your OS to the app you select (e.g. WhatsApp, Mail) |
| **Check for App updates** | App version and platform info | Sent to Apple App Store / Google Play via the Upgrader library to compare versions |
| **Load fonts** | Font files requested from Google Fonts | Request goes to Google’s CDN |
| **Purchase full access** | In-app purchase handled by Google Play or Apple | Payment and purchase history processed by the store; we receive only purchase confirmation through the billing SDK |
| **Restore purchases** | Re-validate prior store purchases | Request sent to Google Play or Apple; we do not receive your payment credentials |

### 4.3 In-app purchases (only if you use paid features)

If you purchase full access to the App, payment is processed entirely by:

- **Google Play Billing** on Android, or  
- **Apple In-App Purchase** on iOS  

We do **not** collect, receive, or store your credit card number, bank account details, or mobile-money credentials. Google or Apple processes payment information according to their own privacy policies and terms.

The App receives from the store only what is needed to unlock features, such as:

- Which product was purchased
- Purchase / entitlement status
- Transaction references provided by the billing platform

We store a **local unlock flag** on your device after a successful purchase so the App can grant access offline. You can use **Restore purchases** to recover access on a new device signed into the same store account.

> **Note:** Paid features may not be enabled in all App versions or regions. This section applies whenever in-app purchase functionality is available.

### 4.4 Information we do **not** collect

We do **not** intentionally collect:

- Email addresses or passwords for user accounts (no accounts exist)
- Precise or approximate location
- Contacts, photos, calendar, or files outside the App’s download folder
- Health, biometric, or government ID data
- Advertising or cross-app tracking identifiers
- Cookies (this is a native mobile app, not a website)

### 4.5 Information collected automatically by third-party SDKs

We use **Firebase Core** and **Cloud Firestore**. When the App connects to Firebase, Google may automatically process certain technical information needed to operate the service, which can include:

- **Device or installation identifiers** (such as Firebase installation IDs or app instance IDs)
- **IP address** and general connection metadata
- **Diagnostic and performance data** related to SDK operation

We do not use Firebase to build user profiles or to track you across other apps or websites. Firebase Analytics is **not enabled** in our App. We do not integrate Google Analytics, Firebase Crashlytics, or advertising SDKs.

For more information, see [Google’s Privacy Policy](https://policies.google.com/privacy) and [Firebase privacy documentation](https://firebase.google.com/support/privacy).

---

## 5. How We Use Information

We use information only to:

1. **Provide core features** — display hymns, favorites, audio player, sheet music viewer, search, and settings  
2. **Sync content** — fetch the latest hymn catalog and media from Firebase  
3. **Improve reliability** — cache content locally for offline use  
4. **Verify in-app purchases** — when you buy or restore full access through Google Play or Apple  
5. **Prompt App updates** — compare your version with the store listing  
6. **Comply with law** — respond to valid legal requests when required  

We do **not** use your data for targeted advertising, profiling, or automated decision-making that affects your legal rights.

---

## 6. Legal Bases for Processing (EEA / UK users)

Where GDPR or UK GDPR applies, we rely on:

| Processing | Legal basis |
|------------|-------------|
| Providing App functionality (catalog, downloads, favorites, settings) | **Performance of a contract** / **legitimate interests** (operating the App you requested) |
| Optional in-app purchases | **Performance of a contract** (when you initiate a purchase through the store) |
| Firebase technical/diagnostic data | **Legitimate interests** (security, stability) and **Google’s role as processor/provider** |
| Legal compliance | **Legal obligation** |

You may withdraw consent for optional processing (e.g. payments) by not using that feature.

---

## 7. How We Share Information

We do **not sell** or **rent** your personal information.

We share data only with the service providers below, strictly to operate the App:

| Recipient | Role | Data shared | Privacy policy |
|-----------|------|-------------|----------------|
| **Google Firebase / Google Cloud** | Hymn catalog (Firestore), media hosting (Storage), SDK infrastructure | Network requests; device/installation identifiers and other technical data as described by Google | [Google Privacy Policy](https://policies.google.com/privacy) |
| **Google Fonts** | Typography | IP address, font requests | [Google Privacy Policy](https://policies.google.com/privacy) |
| **Google Play Billing / Apple In-App Purchase** | Process in-app purchases and restore entitlements (if used) | Purchase status, product ID, transaction metadata handled by the store billing system | [Google Play](https://policies.google.com/privacy) / [Apple](https://www.apple.com/legal/privacy/) |
| **Apple App Store / Google Play** | App distribution and update checks | Standard store metadata via Upgrader | [Apple](https://www.apple.com/legal/privacy/) / [Google Play](https://policies.google.com/privacy) |

We may also disclose information if required by law, court order, or to protect the rights, safety, and security of Full Gospel Mission, our users, or the public.

If Full Gospel Mission is involved in a merger, acquisition, or asset sale, user information may be transferred subject to this policy.

---

## 8. International Data Transfers

Firebase, Google Play, and Apple services may process data on servers located outside your country, including the United States. Where required, those providers offer appropriate safeguards (such as Standard Contractual Clauses) for international transfers.

---

## 9. Data Retention

| Data type | Retention |
|-----------|-----------|
| Local favorites & settings | Until you change them, clear app data, or uninstall the App |
| Downloaded media & hymn cache | Until you use **Clear downloaded data** or uninstall |
| Firestore hymn catalog | Stored on Google Firebase per our content management practices; not tied to individual users |
| In-app purchase records at Google / Apple | Governed by Google Play or Apple retention policies |
| Support emails (if you contact us) | Up to **24 months** after your request is resolved, unless law requires longer |

We do not maintain user account profiles because the App has no login system.

---

## 10. Security

We take reasonable measures to protect information, including:

- **HTTPS/TLS** for network communication with Firebase, Google Play, Apple, and Google services  
- **Read-only** access to Firestore from the App (no user writes to our database)  
- **On-device storage** for personal preferences, not on our own backend  

No method of transmission or storage is 100% secure. You use the App at your own risk.

---

## 11. Device Permissions

The App requires **Internet access** to sync hymns, download media, and connect to Firebase and store services.

On **Android**, when in-app purchases are enabled, the App uses **Google Play Billing**. The billing permission is included automatically by Google’s billing library and is used only to process and restore purchases through Google Play.

We do **not** request permissions for location, camera, microphone, contacts, photo library, or notifications in the current App version.

When you share hymn text, you choose the destination app; we do not control third-party apps you share to.

---

## 12. Your Choices and Rights

### 12.1 In the App

- **Remove favorites** — unfavorite any hymn  
- **Clear downloads** — Settings → Clear downloaded data  
- **Reset preferences** — uninstall the App or clear app storage in device settings  
- **Restore purchases** — recover a prior store purchase on a new device  
- **Stop sharing** — simply do not use the share button  

Purchase history and refunds are managed by **Google Play** or **Apple** according to their policies.

### 12.2 Request data deletion

Because the App does not use user accounts, most of your data is stored **only on your device** and can be removed without contacting us:

1. **In the App:** Settings → **Clear downloaded data** (removes cached hymns, audio, and sheet music)  
2. **On your device:** uninstall the App or clear app storage in your phone’s system settings (removes favorites, preferences, and local unlock status)

If you have contacted us by email and want any correspondence or other data we hold deleted, email us at:

**appsindustry068@gmail.com**

Use the subject line: **Data deletion request**

Please include:

- The app name (**FGM Hymnals - Official - MM**)
- A brief description of what you want deleted
- The email address you used to contact us (if applicable)

We will confirm receipt and respond within **30 days**. Purchase records held by Google Play or Apple must be requested through those platforms according to their policies.

You can also read this policy online at **https://sites.google.com/view/fgmn-hymnal-privacy-policy** or in the App: **Settings → Legal → Privacy Policy**.

### 12.3 Privacy rights (EEA / UK / Switzerland — GDPR)

You have the right to:

- **Access** personal data we hold about you  
- **Rectify** inaccurate data  
- **Erase** data (“right to be forgotten”)  
- **Restrict** processing in certain cases  
- **Data portability** where applicable  
- **Object** to processing based on legitimate interests  
- **Lodge a complaint** with your local supervisory authority  

Because most data is stored only on your device, you can often exercise these rights directly by clearing App data or uninstalling. For requests involving data processed by us or our processors, email **appsindustry068@gmail.com**.

### 12.4 California residents (CCPA / CPRA)

We do **not sell** or **share** personal information for cross-context behavioral advertising.

California residents may request:

- **Access** to personal information collected  
- **Deletion** of personal information  
- **Correction** of inaccurate information  
- **Non-discrimination** for exercising privacy rights  

To submit a request: **appsindustry068@gmail.com**. We will verify and respond within the timeframes required by law.

### 12.5 Other regions

We respect applicable privacy laws in your jurisdiction. Contact us to exercise rights available under local law.

---

## 13. Children’s Privacy

The App is a general hymnals application and is **not directed at children under 13** (or the applicable age of digital consent in your country, e.g. **16** in some EU member states).

We do **not** knowingly collect personal information from children. If you believe a child has provided personal information through payment or support channels, contact us at **appsindustry068@gmail.com** and we will take steps to delete it.

Parents and guardians should supervise children’s use of the App and any sharing or payment features.

---

## 14. Third-Party Links and Services

The App may open downloaded files in external viewers (PDF/image/audio apps) via the operating system. Those apps have their own privacy policies.

Media files may be loaded from Firebase Storage. In-app purchases are handled by Google Play or Apple. We are not responsible for third-party services you choose to use outside the App.

---

## 15. Changes to This Policy

We may update this Privacy Policy from time to time. When we do, we will revise the **“Last updated”** date at the top. Material changes may also be communicated in the App or on our website.

Continued use of the App after an update means you accept the revised policy.

---

## 16. Contact Us

For privacy questions, requests, or complaints:

**Full Gospel Mission**  
Email: **appsindustry068@gmail.com**  
Address: **Bepanda Casmando, Bepanda 00000, Douala, Cameroon**  
Organization website: **https://fullgospel-mission.org/**  
Privacy policy: **https://sites.google.com/view/fgmn-hymnal-privacy-policy**

We aim to respond within **30 days**.

---

## 17. App Store Data Safety Summary (Reference)

For Google Play and Apple App Store “Data safety” / “Privacy Nutrition Label” declarations, the App generally:

| Declares | Details |
|----------|---------|
| **Data collected** | Purchase history processed by Google Play or Apple when you buy in-app; device/installation identifiers and diagnostic data via Firebase per Google |
| **Data not collected** | Payment card numbers, bank accounts, mobile-money numbers, location, contacts, photos, audio recordings from mic — not collected by us |
| **Data shared** | Purchase validation with Google Play / Apple; technical and identifier data with Google/Firebase as described above |
| **Encryption in transit** | Yes (HTTPS) |
| **User can request deletion** | Yes — in-app (Settings → Clear downloaded data), device settings, or email **appsindustry068@gmail.com** with subject **Data deletion request** |
| **Independent security review** | No |

Adjust store declarations if payment features are disabled in a given release.

---

*© Full Gospel Mission. All rights reserved.*

---
---

# Politique de confidentialité — MPE Cantiques - Officiel - MM

**Date d’entrée en vigueur :** 17 juillet 2026  
**Dernière mise à jour :** 1er août 2026

---

## 1. Introduction

Full Gospel Mission (« **nous** ») exploite **MPE Cantiques - Officiel - MM** (l’« **Application** »), une application mobile qui vous permet de consulter des paroles de cantiques, des partitions et des enregistrements audio publiés par Full Gospel Mission.

La présente Politique de confidentialité explique quelles informations sont traitées lorsque vous utilisez l’Application, comment nous les utilisons, avec qui nous les partageons, et quels choix vous avez. Elle s’applique à l’Application sur Android, iOS et les autres plateformes où elle est distribuée.

En utilisant l’Application, vous acceptez les pratiques décrites dans cette politique. Si vous n’êtes pas d’accord, veuillez ne pas utiliser l’Application.

---

## 2. Qui est responsable de vos données

**Responsable du traitement :**  
Full Gospel Mission  
Bepanda Casmando  
Bepanda 00000  
Douala, Cameroun

**Contact confidentialité :**  
E-mail : appsindustry068@gmail.com

Pour les utilisateurs situés dans l’Espace économique européen (EEE), au Royaume-Uni ou en Suisse, Full Gospel Mission est le responsable du traitement des données personnelles décrites dans cette politique.

---

## 3. Résumé

| Sujet | Ce que fait l’Application |
|-------|---------------------------|
| Comptes utilisateur | **Non.** L’Application ne nécessite ni inscription ni connexion. |
| Publicité | **Non.** Nous n’affichons pas de publicités et n’utilisons pas d’identifiants publicitaires. |
| Analytique | **Pas de SDK d’analytique dédié.** Nous n’utilisons pas Google Analytics ni d’outils similaires dans l’application. |
| Identifiants d’appareil | **Via Firebase uniquement** — des identifiants d’installation/d’appareil peuvent être traités par Google pour faire fonctionner les services Firebase. |
| Localisation | **Non.** Nous ne collectons pas de position GPS ni de localisation précise. |
| Caméra / microphone / contacts | **Non.** Ces éléments ne sont pas utilisés. |
| Favoris et réglages | Stockés **uniquement sur votre appareil**. |
| Catalogue de cantiques | Téléchargé depuis **Google Firebase (Firestore)**. |
| Audio et partitions | Téléchargés depuis **Firebase Storage** lorsque vous les demandez. |
| Partage des paroles | Utilise la **feuille de partage système** de votre appareil ; nous ne recevons pas le contenu partagé. |
| Paiements (si activés) | Traités par **Google Play Billing** (Android) ou **Apple In-App Purchase** (iOS) ; nous ne collectons ni ne stockons les détails de carte bancaire. |

---

## 4. Informations que nous collectons

Nous collectons uniquement les informations nécessaires au fonctionnement de l’Application. Nous **ne vendons pas** vos informations personnelles.

### 4.1 Informations stockées localement sur votre appareil

Les données suivantes restent sur votre appareil tant que vous ne supprimez pas l’Application ou ne les effacez pas via les réglages :

| Donnée | Finalité | Stockage |
|--------|----------|----------|
| **Cantiques favoris** | Enregistrer les cantiques que vous marquez comme favoris | Uniquement sur votre appareil |
| **Préférence de thème** | Thème clair, sombre ou système | Uniquement sur votre appareil |
| **Couleur d’accent** | Choix de couleur de l’interface | Uniquement sur votre appareil |
| **Taille et police** | Préférences d’affichage du texte des cantiques | Uniquement sur votre appareil |
| **Catalogue de cantiques en cache** | Accès hors ligne aux métadonnées | Uniquement sur votre appareil |
| **Fichiers audio téléchargés** | Lecture hors ligne | Uniquement sur votre appareil |
| **Partitions téléchargées** | Consultation hors ligne | Uniquement sur votre appareil |
| **Statut de déblocage d’achat** | Se souvenir que l’accès complet a été acheté | Uniquement sur votre appareil |

Ces données **ne sont pas envoyées sur nos serveurs** et **ne sont pas liées à votre identité**, car l’Application n’a pas de comptes utilisateur.

Vous pouvez supprimer les audios, partitions et le cache des cantiques à tout moment dans **Réglages → Effacer les données téléchargées**. Les favoris et préférences d’apparence sont supprimés lorsque vous désinstallez l’Application ou effacez les données de l’application au niveau du système.

### 4.2 Informations traitées lors de l’utilisation des fonctionnalités

| Activité | Données concernées | Envoyées à nous ? |
|----------|--------------------|-------------------|
| **Parcourir / rechercher des cantiques** | Les termes de recherche sont traités uniquement en mémoire sur votre appareil | Non |
| **Actualiser le catalogue** | L’Application demande des documents de cantiques à Firestore | Lecture seule ; aucun identifiant utilisateur attaché par notre code |
| **Télécharger audio ou partition** | Requête HTTP vers l’URL Firebase Storage du cantique sélectionné | La requête va vers Google/Firebase ; nous n’enregistrons pas votre identité |
| **Partager un cantique** | Titre, numéro et paroles que vous choisissez de partager | Non — le partage passe directement par votre système vers l’application choisie (ex. WhatsApp, Mail) |
| **Vérifier les mises à jour** | Version de l’app et informations de plateforme | Envoyées à l’App Store / Google Play via la bibliothèque Upgrader |
| **Charger les polices** | Fichiers de polices demandés à Google Fonts | Requête vers le CDN de Google |
| **Acheter l’accès complet** | Achat intégré géré par Google Play ou Apple | Paiement et historique d’achat traités par la boutique ; nous recevons uniquement la confirmation via le SDK de facturation |
| **Restaurer les achats** | Revalidation des achats antérieurs | Demande envoyée à Google Play ou Apple ; nous ne recevons pas vos identifiants de paiement |

### 4.3 Achats intégrés (uniquement si vous utilisez les fonctionnalités payantes)

Si vous achetez l’accès complet à l’Application, le paiement est entièrement traité par :

- **Google Play Billing** sur Android, ou  
- **Apple In-App Purchase** sur iOS  

Nous **ne collectons, ne recevons ni ne stockons** votre numéro de carte bancaire, vos coordonnées bancaires ni vos identifiants mobile money. Google ou Apple traitent les informations de paiement selon leurs propres politiques de confidentialité et conditions.

L’Application reçoit de la boutique uniquement ce qui est nécessaire pour débloquer les fonctionnalités, notamment :

- Quel produit a été acheté
- Le statut d’achat / d’entitlement
- Les références de transaction fournies par la plateforme de facturation

Nous stockons un **indicateur local de déblocage** sur votre appareil après un achat réussi afin que l’Application puisse accorder l’accès hors ligne. Vous pouvez utiliser **Restaurer les achats** pour récupérer l’accès sur un nouvel appareil connecté au même compte boutique.

> **Remarque :** Les fonctionnalités payantes peuvent ne pas être activées dans toutes les versions ou régions. Cette section s’applique dès que la fonctionnalité d’achat intégré est disponible.

### 4.4 Informations que nous **ne** collectons **pas**

Nous ne collectons **pas** intentionnellement :

- Adresses e-mail ou mots de passe pour des comptes utilisateur (aucun compte n’existe)
- Localisation précise ou approximative
- Contacts, photos, calendrier, ou fichiers hors du dossier de téléchargement de l’Application
- Données de santé, biométriques ou d’identité officielle
- Identifiants publicitaires ou de suivi inter-applications
- Cookies (il s’agit d’une application mobile native, pas d’un site web)

### 4.5 Informations collectées automatiquement par des SDK tiers

Nous utilisons **Firebase Core** et **Cloud Firestore**. Lorsque l’Application se connecte à Firebase, Google peut automatiquement traiter certaines informations techniques nécessaires au service, notamment :

- **Identifiants d’appareil ou d’installation** (tels que les Firebase Installation IDs ou app instance IDs)
- **Adresse IP** et métadonnées de connexion générales
- **Données de diagnostic et de performance** liées au fonctionnement du SDK

Nous n’utilisons pas Firebase pour créer des profils utilisateur ni pour vous suivre sur d’autres applications ou sites web. Firebase Analytics **n’est pas activé** dans notre Application. Nous n’intégrons ni Google Analytics, ni Firebase Crashlytics, ni de SDK publicitaires.

Pour plus d’informations, consultez la [Politique de confidentialité de Google](https://policies.google.com/privacy) et la [documentation confidentialité Firebase](https://firebase.google.com/support/privacy).

---

## 5. Comment nous utilisons les informations

Nous utilisons les informations uniquement pour :

1. **Fournir les fonctionnalités principales** — affichage des cantiques, favoris, lecteur audio, visionneuse de partitions, recherche et réglages  
2. **Synchroniser le contenu** — récupérer le catalogue et les médias depuis Firebase  
3. **Améliorer la fiabilité** — mettre le contenu en cache pour un usage hors ligne  
4. **Vérifier les achats intégrés** — lorsque vous achetez ou restaurez l’accès complet via Google Play ou Apple  
5. **Proposer des mises à jour** — comparer votre version avec la fiche de la boutique  
6. **Respecter la loi** — répondre aux demandes légales valides lorsque cela est requis  

Nous n’utilisons **pas** vos données pour de la publicité ciblée, du profilage, ni pour une prise de décision automatisée affectant vos droits.

---

## 6. Bases légales du traitement (utilisateurs EEE / Royaume-Uni)

Lorsque le RGPD ou le UK GDPR s’applique, nous nous fondons sur :

| Traitement | Base légale |
|------------|-------------|
| Fourniture des fonctionnalités (catalogue, téléchargements, favoris, réglages) | **Exécution d’un contrat** / **intérêts légitimes** (exploitation de l’Application que vous avez demandée) |
| Achats intégrés optionnels | **Exécution d’un contrat** (lorsque vous initiez un achat via la boutique) |
| Données techniques/diagnostiques Firebase | **Intérêts légitimes** (sécurité, stabilité) et **rôle de Google en tant que sous-traitant/fournisseur** |
| Conformité légale | **Obligation légale** |

Vous pouvez retirer votre consentement pour un traitement optionnel (ex. paiements) en n’utilisant pas cette fonctionnalité.

---

## 7. Comment nous partageons les informations

Nous **ne vendons** ni **ne louons** vos informations personnelles.

Nous partageons des données uniquement avec les prestataires ci-dessous, strictement pour faire fonctionner l’Application :

| Destinataire | Rôle | Données partagées | Politique de confidentialité |
|--------------|------|-------------------|------------------------------|
| **Google Firebase / Google Cloud** | Catalogue de cantiques (Firestore), hébergement des médias (Storage), infrastructure SDK | Requêtes réseau ; identifiants d’appareil/d’installation et autres données techniques selon Google | [Politique Google](https://policies.google.com/privacy) |
| **Google Fonts** | Typographie | Adresse IP, requêtes de polices | [Politique Google](https://policies.google.com/privacy) |
| **Google Play Billing / Apple In-App Purchase** | Traitement des achats intégrés et restauration des droits (si utilisés) | Statut d’achat, ID produit, métadonnées de transaction gérées par le système de facturation | [Google Play](https://policies.google.com/privacy) / [Apple](https://www.apple.com/legal/privacy/) |
| **Apple App Store / Google Play** | Distribution et vérification des mises à jour | Métadonnées standard de boutique via Upgrader | [Apple](https://www.apple.com/legal/privacy/) / [Google Play](https://policies.google.com/privacy) |

Nous pouvons également divulguer des informations si la loi, une décision de justice ou la protection des droits, de la sécurité et de la sûreté de Full Gospel Mission, de nos utilisateurs ou du public l’exige.

Si Full Gospel Mission est impliquée dans une fusion, une acquisition ou une cession d’actifs, les informations utilisateurs peuvent être transférées sous réserve de la présente politique.

---

## 8. Transferts internationaux de données

Firebase, Google Play et les services Apple peuvent traiter des données sur des serveurs situés hors de votre pays, y compris aux États-Unis. Le cas échéant, ces prestataires proposent des garanties appropriées (telles que les clauses contractuelles types) pour les transferts internationaux.

---

## 9. Conservation des données

| Type de donnée | Durée de conservation |
|----------------|----------------------|
| Favoris et réglages locaux | Jusqu’à ce que vous les modifiiez, effaciez les données de l’app ou désinstalliez l’Application |
| Médias téléchargés et cache des cantiques | Jusqu’à **Effacer les données téléchargées** ou désinstallation |
| Catalogue Firestore | Stocké sur Google Firebase selon nos pratiques de gestion de contenu ; non lié à des utilisateurs individuels |
| Historique d’achats chez Google / Apple | Régi par les politiques de conservation de Google Play ou Apple |
| E-mails d’assistance (si vous nous contactez) | Jusqu’à **24 mois** après résolution de votre demande, sauf obligation légale plus longue |

Nous ne maintenons pas de profils de compte utilisateur, car l’Application n’a pas de système de connexion.

---

## 10. Sécurité

Nous prenons des mesures raisonnables pour protéger les informations, notamment :

- **HTTPS/TLS** pour les communications réseau avec Firebase, Google Play, Apple et les services Google  
- Accès **en lecture seule** à Firestore depuis l’Application (aucune écriture utilisateur dans notre base)  
- **Stockage sur l’appareil** pour les préférences personnelles, pas sur notre propre backend  

Aucune méthode de transmission ou de stockage n’est sécurisée à 100 %. Vous utilisez l’Application à vos propres risques.

---

## 11. Autorisations de l’appareil

L’Application nécessite un **accès Internet** pour synchroniser les cantiques, télécharger les médias et se connecter à Firebase et aux services des boutiques.

Sur **Android**, lorsque les achats intégrés sont activés, l’Application utilise **Google Play Billing**. L’autorisation de facturation est incluse automatiquement par la bibliothèque de facturation de Google et sert uniquement à traiter et restaurer les achats via Google Play.

Nous **ne demandons pas** d’autorisations pour la localisation, la caméra, le microphone, les contacts, la photothèque ou les notifications dans la version actuelle de l’Application.

Lorsque vous partagez le texte d’un cantique, vous choisissez l’application de destination ; nous ne contrôlons pas les applications tierces vers lesquelles vous partagez.

---

## 12. Vos choix et vos droits

### 12.1 Dans l’Application

- **Retirer des favoris** — retirer n’importe quel cantique des favoris  
- **Effacer les téléchargements** — Réglages → Effacer les données téléchargées  
- **Réinitialiser les préférences** — désinstaller l’Application ou effacer le stockage de l’app dans les réglages système  
- **Restaurer les achats** — récupérer un achat boutique antérieur sur un nouvel appareil  
- **Ne plus partager** — n’utilisez simplement pas le bouton de partage  

L’historique d’achats et les remboursements sont gérés par **Google Play** ou **Apple** selon leurs politiques.

### 12.2 Demande de suppression des données

Comme l’Application n’utilise pas de comptes utilisateur, la plupart de vos données sont stockées **uniquement sur votre appareil** et peuvent être supprimées sans nous contacter :

1. **Dans l’Application :** Réglages → **Effacer les données téléchargées** (supprime le cache des cantiques, l’audio et les partitions)  
2. **Sur votre appareil :** désinstallez l’Application ou effacez le stockage de l’app dans les réglages système (supprime favoris, préférences et statut local de déblocage)

Si vous nous avez contactés par e-mail et souhaitez que toute correspondance ou autre donnée que nous détenons soit supprimée, écrivez-nous à :

**appsindustry068@gmail.com**

Utilisez l’objet : **Demande de suppression de données**

Veuillez indiquer :

- Le nom de l’application (**MPE Cantiques - Officiel - MM**)
- Une brève description de ce que vous souhaitez supprimer
- L’adresse e-mail utilisée pour nous contacter (le cas échéant)

Nous confirmerons la réception et répondrons dans un délai de **30 jours**. Les enregistrements d’achat détenus par Google Play ou Apple doivent être demandés via ces plateformes selon leurs politiques.

Vous pouvez aussi lire cette politique en ligne sur **https://sites.google.com/view/fgmn-hymnal-privacy-policy** ou dans l’Application : **Réglages → Mentions légales → Politique de confidentialité**.

### 12.3 Droits à la vie privée (EEE / Royaume-Uni / Suisse — RGPD)

Vous avez le droit de :

- **Accéder** aux données personnelles que nous détenons à votre sujet  
- **Rectifier** les données inexactes  
- **Effacer** les données (« droit à l’oubli »)  
- **Limiter** le traitement dans certains cas  
- **Portabilité** des données le cas échéant  
- **Vous opposer** au traitement fondé sur les intérêts légitimes  
- **Déposer une plainte** auprès de votre autorité de contrôle locale  

Comme la plupart des données sont stockées uniquement sur votre appareil, vous pouvez souvent exercer ces droits directement en effaçant les données de l’Application ou en la désinstallant. Pour les demandes portant sur des données traitées par nous ou nos sous-traitants, écrivez à **appsindustry068@gmail.com**.

### 12.4 Résidents de Californie (CCPA / CPRA)

Nous **ne vendons** ni **ne partageons** d’informations personnelles à des fins de publicité comportementale contextuelle croisée.

Les résidents de Californie peuvent demander :

- **L’accès** aux informations personnelles collectées  
- **La suppression** des informations personnelles  
- **La correction** des informations inexactes  
- **La non-discrimination** pour l’exercice de leurs droits  

Pour soumettre une demande : **appsindustry068@gmail.com**. Nous vérifierons et répondrons dans les délais prévus par la loi.

### 12.5 Autres régions

Nous respectons les lois sur la protection de la vie privée applicables dans votre juridiction. Contactez-nous pour exercer les droits disponibles selon le droit local.

---

## 13. Confidentialité des enfants

L’Application est une application générale de cantiques et **n’est pas destinée aux enfants de moins de 13 ans** (ou à l’âge du consentement numérique applicable dans votre pays, par ex. **16 ans** dans certains États membres de l’UE).

Nous ne collectons **pas** sciemment d’informations personnelles auprès d’enfants. Si vous pensez qu’un enfant a fourni des informations personnelles via un paiement ou un canal d’assistance, contactez-nous à **appsindustry068@gmail.com** et nous prendrons des mesures pour les supprimer.

Les parents et tuteurs doivent superviser l’utilisation de l’Application par les enfants, y compris le partage et les fonctionnalités de paiement.

---

## 14. Liens et services tiers

L’Application peut ouvrir des fichiers téléchargés dans des visionneuses externes (PDF/image/audio) via le système d’exploitation. Ces applications ont leurs propres politiques de confidentialité.

Les fichiers multimédias peuvent être chargés depuis Firebase Storage. Les achats intégrés sont gérés par Google Play ou Apple. Nous ne sommes pas responsables des services tiers que vous choisissez d’utiliser en dehors de l’Application.

---

## 15. Modifications de cette politique

Nous pouvons mettre à jour cette Politique de confidentialité de temps à autre. Dans ce cas, nous réviserons la date de **« Dernière mise à jour »** en haut du document. Les changements importants peuvent aussi être communiqués dans l’Application ou sur notre site web.

L’utilisation continue de l’Application après une mise à jour signifie que vous acceptez la politique révisée.

---

## 16. Nous contacter

Pour toute question, demande ou réclamation relative à la confidentialité :

**Full Gospel Mission**  
E-mail : **appsindustry068@gmail.com**  
Adresse : **Bepanda Casmando, Bepanda 00000, Douala, Cameroun**  
Site de l’organisation : **https://fullgospel-mission.org/**  
Politique de confidentialité : **https://sites.google.com/view/fgmn-hymnal-privacy-policy**

Nous visons à répondre sous **30 jours**.

---

## 17. Résumé Data Safety / étiquette de confidentialité (référence)

Pour les déclarations Google Play « Data safety » et Apple « Privacy Nutrition Label », l’Application déclare généralement :

| Déclaration | Détails |
|-------------|---------|
| **Données collectées** | Historique d’achat traité par Google Play ou Apple lors d’un achat intégré ; identifiants d’appareil/d’installation et données de diagnostic via Firebase selon Google |
| **Données non collectées** | Numéros de carte, comptes bancaires, numéros mobile money, localisation, contacts, photos, enregistrements micro — non collectés par nous |
| **Données partagées** | Validation d’achat avec Google Play / Apple ; données techniques et identifiants avec Google/Firebase comme décrit ci-dessus |
| **Chiffrement en transit** | Oui (HTTPS) |
| **Demande de suppression possible** | Oui — dans l’app (Réglages → Effacer les données téléchargées), réglages appareil, ou e-mail **appsindustry068@gmail.com** avec l’objet **Demande de suppression de données** |
| **Audit de sécurité indépendant** | Non |

Adaptez les déclarations boutique si les fonctionnalités de paiement sont désactivées dans une version donnée.

---

*© Full Gospel Mission. Tous droits réservés.*
