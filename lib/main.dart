import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/splash/splash_screen.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
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
    final lightScheme = AppThemeColors.lightScheme();
    final darkScheme = AppThemeColors.darkScheme();

    // App-wide UI font. Fraunces is applied explicitly where needed
    // (hymn titles, verse/chorus body, number badges).
    TextTheme lightTextTheme;
    TextTheme darkTextTheme;
    String? fontFamily;
    try {
      fontFamily = GoogleFonts.inter().fontFamily;
      lightTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
      darkTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    } catch (e) {
      fontFamily = null;
      lightTextTheme = ThemeData.light().textTheme;
      darkTextTheme = ThemeData.dark().textTheme;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: Locale(ref.watch(deviceLocaleProvider)),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        fontFamily: fontFamily,
        textTheme: lightTextTheme.apply(
          bodyColor: lightScheme.onSurface,
          displayColor: lightScheme.onSurface,
        ),
        brightness: Brightness.light,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: AppThemeColors.lightScaffold,
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(width: 1, color: lightScheme.primary),
          ),
          fillColor: Colors.grey.withAlpha(15),
          filled: true,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: lightScheme.primary,
          circularTrackColor: lightScheme.primary.withValues(alpha: 0.14),
          strokeWidth: 3.25,
          strokeCap: StrokeCap.round,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: fontFamily,
        textTheme: darkTextTheme.apply(
          bodyColor: darkScheme.onSurface,
          displayColor: darkScheme.onSurface,
        ),
        brightness: Brightness.dark,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: AppThemeColors.darkScaffold,
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
            borderSide: BorderSide(width: 1, color: darkScheme.primary),
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
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: darkScheme.primary,
          circularTrackColor: darkScheme.primary.withValues(alpha: 0.18),
          strokeWidth: 3.25,
          strokeCap: StrokeCap.round,
        ),
      ),
      themeMode: themeMode,
      home: UpgradeAlert(
        navigatorKey: rootNavigatorKey,
        barrierDismissible: false,
        showIgnore: false,
        showLater: false,
        shouldPopScope: () => false,
        upgrader: Upgrader(durationUntilAlertAgain: Duration.zero),
        child: const SplashScreen(),
      ),
    );
  }
}
