import 'dart:async';

import 'package:fgm_lyrics_app/app/locale/locale_provider.dart';
import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/notifications/praise_notification_service.dart';
import 'package:fgm_lyrics_app/app/splash/splash_screen.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/styled_upgrade_alert.dart';
import 'package:fgm_lyrics_app/core/theme/app_fonts.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // Warm SharedPreferences so locale/theme providers can read any saved
  // user choice quickly; first install still follows the device.
  await SharedPreferences.getInstance();
  // On Android (and other native platforms), Firebase will read configuration
  // from platform-specific files (e.g. google-services.json on Android).
  await Firebase.initializeApp();
  await PraiseNotificationService.instance.init();
  // Preload Google Fonts while splash is about to show (IBM Plex Sans,
  // Fraunces, and hymn body options from settings).
  await AppFonts.preload();
  // Fire-and-forget so splash is not blocked by permission dialogs.
  unawaited(
    PraiseNotificationService.instance.syncSchedule().catchError((
      Object e,
      StackTrace st,
    ) {
      debugPrint('Praise reminders sync failed: $e\n$st');
    }),
  );
  runApp(const ProviderScope(child: HymnApp()));
}

class HymnApp extends ConsumerWidget {
  const HymnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // App-wide UI font. Fraunces is applied explicitly where needed
    // (hymn titles, verse/chorus body, number badges).
    TextTheme lightTextTheme;
    TextTheme darkTextTheme;
    String? fontFamily;
    try {
      fontFamily = GoogleFonts.ibmPlexSans().fontFamily;
      lightTextTheme = GoogleFonts.ibmPlexSansTextTheme(
        ThemeData.light().textTheme,
      );
      darkTextTheme = GoogleFonts.ibmPlexSansTextTheme(
        ThemeData.dark().textTheme,
      );
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
      theme: AppTheme.light(textTheme: lightTextTheme, fontFamily: fontFamily),
      darkTheme: AppTheme.dark(
        textTheme: darkTextTheme,
        fontFamily: fontFamily,
      ),
      themeMode: themeMode,
      home: StyledUpgradeAlert(
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
