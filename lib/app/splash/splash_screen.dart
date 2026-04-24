import 'package:fgm_lyrics_app/app/lyric/screens/lyric_list_screen.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LyricListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white70, Colors.white60],
            stops: [0.0, 0.9, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/logo.png',
                width: size.width * 0.6,
                height: size.width * 0.6,
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(
                strokeCap: StrokeCap.round,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.red.withAlpha(200),
                ),
                strokeWidth: 3,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Image.asset('assets/logo2.png', width: 20, height: 20),
                  Text(
                    l10n.splashOrganizationName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.blueGrey.shade700,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.roboto().fontFamily,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
