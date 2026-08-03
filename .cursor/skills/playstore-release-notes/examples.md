# Play Store release notes — examples

## Example A — feature (minor) bump

**Context:** Projection mode, FR/EN toggle on detail, search in lyrics.  
**From:** `1.1.2+7` → **To:** `1.2.0+8`

**EN**

```
What's new in 1.2.0

• Switch a hymn between French and English from the detail screen
• New Projection mode for verse-by-verse display on a projector
• Search finds hymns by title or lyrics
• Floating navigation and music player with smoother animations
• Cleaner bilingual hymn lists and polished reading layout
• Stability and privacy updates for Google Play
```

**FR**

```
Nouveautés de la version 1.2.0

• Basculez un cantique entre le français et l’anglais depuis le détail
• Nouveau mode Projection pour afficher couplet par couplet (vidéoprojecteur)
• La recherche trouve aussi les paroles, pas seulement le titre
• Navigation et lecteur audio flottants, animations plus fluides
• Listes bilingues plus claires et lecture plus confortable
• Stabilité et confidentialité mises à jour pour Google Play
```

## Example B — polish / fix (patch) bump

**Context:** Thinner player controls, menu sheet instead of drawer, typography cleanup.  
**From:** `1.2.0+8` → **To:** `1.2.1+9`

**EN**

```
What's new in 1.2.1

• Clearer music player controls with quicker ±5 second skips
• Faster menu access from the hymn list
• Projection stage stays fixed so lyrics stay centered
• Tab bar and language switch show again when you scroll to the top
• Typography and sheet-music screens polished
```

**FR**

```
Nouveautés de la version 1.2.1

• Lecteur audio plus clair avec avance/retour rapide de ±5 secondes
• Menu plus accessible depuis la liste des cantiques
• Zone de projection fixe pour garder les paroles centrées
• La barre d’onglets et la langue réapparaissent en haut de page
• Typographie et écran partition affinés
```

## Tone rules illustrated

| Prefer | Avoid |
|--------|-------|
| “Search finds hymns by title or lyrics” | “Improved HymnSearch matcher regex” |
| “Music player with skip ±5 seconds” | “Refactored `_SeekChip` widget” |
| “Menu opens as a floating sheet” | “Replaced Scaffold.drawer with ModalBottomSheet” |
