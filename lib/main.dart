import 'package:fgm_lyrics_app/app/locale/theme_provider.dart';
import 'package:fgm_lyrics_app/app/lyric/screens/lyric_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final Store store = await openStore(directory: Directory('lyrics_db'));
  runApp(const ProviderScope(child: HymnApp()));
}

class HymnApp extends ConsumerWidget {
  const HymnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    // Safe font family with fallbacks
    String? fontFamily;
    try {
      fontFamily = GoogleFonts.lato().fontFamily;
    } catch (e) {
      // Fallback to system fonts if Google Fonts fails
      fontFamily = null; // Will use default system font
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FGM Hymns',
      theme: ThemeData(
        fontFamily: fontFamily,
        fontFamilyFallback: const [
          'SF Pro Text', // iOS
          'Roboto', // Android
          'Segoe UI', // Windows
          'Arial', // Fallback
        ],
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
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

            borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.withAlpha(20)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),

            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          fillColor: Colors.grey.withAlpha(15),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: fontFamily,
        fontFamilyFallback: const [
          'SF Pro Text', // iOS
          'Roboto', // Android
          'Segoe UI', // Windows
          'Arial', // Fallback
        ],
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
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
            borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
          ),
          fillColor: Colors.grey.withAlpha(15),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
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
      home: const LyricListScreen(),
    );
  }
}
