import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/settings/theme_seed_color_provider.dart';
import 'package:fgm_lyrics_app/app/splash/splash_screen.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // On Android (and other native platforms), Firebase will read configuration
  // from platform-specific files (e.g. google-services.json on Android).
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: HymnApp()));
}

class HymnApp extends ConsumerWidget {
  const HymnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final seedIndex = ref.watch(themeSeedIndexProvider);
    final seedColor =
        kThemeSeedColors[seedIndex.clamp(0, kThemeSeedColors.length - 1)];
    final lightScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    // Safe font family with fallbacks
    String? fontFamily;
    try {
      fontFamily = GoogleFonts.roboto().fontFamily;
    } catch (e) {
      // Fallback to system fonts if Google Fonts fails
      fontFamily = null; // Will use default system font
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: Locale(ref.watch(deviceLocaleProvider)),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        fontFamily: fontFamily,
        brightness: Brightness.light,
        colorScheme: lightScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: lightScheme.primary,
            foregroundColor: lightScheme.onPrimary,
            textStyle: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey.withAlpha(400)),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),

            // borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            // borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),

            borderSide: BorderSide(width: 1, color: lightScheme.secondary),
          ),
          fillColor: Colors.grey.withAlpha(15),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: fontFamily,
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintStyle: TextStyle(color: Colors.grey.withAlpha(400)),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1, color: darkScheme.secondary),
          ),
          fillColor: Colors.grey.withAlpha(15),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: darkScheme.primary,
            foregroundColor: darkScheme.onPrimary,
            textStyle: TextStyle(
              fontFamily: fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            shape: const StadiumBorder(),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
      themeMode: themeMode,
      home: UpgradeAlert(
        navigatorKey: rootNavigatorKey,
        upgrader: Upgrader(),
        child: const SplashScreen(),
      ),
    );
  }
}
