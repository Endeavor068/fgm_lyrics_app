# Changelog

All notable changes to FGM Hymns are documented in this file.

## [1.2.0] — 2026-08-01

**Build:** `1.2.0+8`

### Added
- Switch French ↔ English hymn versions from the hymn detail screen (with a clear message when a translation is missing)
- Projection mode: display verses and chorus slide by slide (fullscreen ready for projectors)
- Search now matches titles **and** lyrics (verses & chorus)
- Floating bottom navigation bar that gently hides while scrolling
- Floating music player on the Lyrics tab (progress, play/pause, ±10 s)
- Force update prompt when a newer store version is available
- Localized app name on the device launcher (EN / FR)

### Changed
- Cleaner hymn lists: each language only shows hymns that actually exist in that language
- Redesigned home list, detail header, favorites, and settings for a more focused reading experience
- Sheet music viewer spacing and PDF pinch-to-zoom layout polished
- Privacy policy and billing aligned with Google Play In-App Purchases (PayUnit / mobile money removed)

### Fixed
- Settings list tiles ink splash visibility (Material wrapping)
- Various scroll and layout glitches on sheet music and projection

### Notes for Google Play Console (“What’s new”)

**English (default)** — copy into Play Console (≤ 500 characters)

```
What's new in 1.2.0

• Switch a hymn between French and English from the detail screen
• New Projection mode for verse-by-verse display on a projector
• Search finds hymns by title or lyrics
• Floating navigation and music player with smoother animations
• Cleaner bilingual hymn lists and polished reading layout
• Stability and privacy updates for Google Play
```

**Français**

```
Nouveautés de la version 1.2.0

• Basculez un cantique entre le français et l’anglais depuis le détail
• Nouveau mode Projection pour afficher couplet par couplet (vidéoprojecteur)
• La recherche trouve aussi les paroles, pas seulement le titre
• Navigation et lecteur audio flottants, animations plus fluides
• Listes bilingues plus claires et lecture plus confortable
• Stabilité et confidentialité mises à jour pour Google Play
```

---

## [1.1.0] — 2026-07-17

**Build:** `1.1.0+5`

### Added
- Full in-app music player on the Lyrics tab: progress bar, elapsed/total time, play/pause, and ±10 second seek controls
- Google Play in-app purchase support (lifetime unlock) with restore purchases
- Privacy Policy link in Settings (Legal section)

### Changed
- Replaced the floating play button with a bottom player bar (Lyrics tab only; hidden on Sheet Music)
- Switched from mobile-money (PayUnit) to Google Play Billing
- Updated privacy policy for Google Play compliance

### Notes for Google Play Console (“What’s new”)

**English (default)**
```
What's new in 1.1.0

• Full music player on Lyrics: play/pause, progress bar, and skip ±10 seconds
• Purchase lifetime access securely via Google Play (restore purchases supported)
• Privacy Policy now available in Settings
• Performance and dependency updates
```

**Français**
```
Nouveautés de la version 1.1.0

• Lecteur audio complet sur Paroles : lecture/pause, barre de progression et ±10 s
• Achat d’accès à vie via Google Play (restauration des achats prise en charge)
• Politique de confidentialité accessible dans Réglages
• Améliorations de performance et mises à jour
```

---

## [1.0.0] — previous

Initial Play Store release (`1.0.0+4`): browse hymns, lyrics & sheet music, favorites, search, audio playback, multilingual UI (EN/FR), and settings.
