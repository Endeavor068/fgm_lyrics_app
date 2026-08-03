import 'dart:async';

import 'package:fgm_lyrics_app/app/lyric/screens/lyric_list_screen.dart';
import 'package:fgm_lyrics_app/core/shared/widgets/app_progress_indicator.dart';
import 'package:fgm_lyrics_app/core/theme/app_fonts.dart';
import 'package:fgm_lyrics_app/core/theme/app_theme_colors.dart';
import 'package:fgm_lyrics_app/core/utils/image_decode.dart';
import 'package:fgm_lyrics_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _navigateAfter = Duration(milliseconds: 2200);

  late final AnimationController _entranceController;
  late final AnimationController _breathController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<double> _riseIn;
  late final Animation<double> _breath;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _scaleIn = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _riseIn = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _breath = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _entranceController.forward().whenComplete(() {
      if (mounted) _breathController.repeat(reverse: true);
    });

    _navTimer = Timer(_navigateAfter, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, _, _) => const LyricListScreen(),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 420),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _navTimer = null;
    _breathController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final logoSize = size.shortestSide * 0.42;

    return Scaffold(
      backgroundColor: AppThemeColors.lightScaffold,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFFCF8),
                  AppThemeColors.lightScaffold,
                  Color(0xFFF6EFE6),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _entranceController,
                  _breathController,
                ]),
                builder: (context, _) {
                  final logoScale = _scaleIn.value * _breath.value;
                  return Column(
                    children: [
                      const Spacer(flex: 3),
                      Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _riseIn.value),
                          child: Transform.scale(
                            scale: logoScale,
                            child: SizedBox(
                              width: logoSize * 1.35,
                              height: logoSize * 1.35,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Soft brand halo behind the flame logo.
                                  Container(
                                    width: logoSize * 1.15,
                                    height: logoSize * 1.15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppThemeColors.lightSeed.withValues(
                                            alpha: 0.16 * _fadeIn.value,
                                          ),
                                          AppThemeColors.lightSeed.withValues(
                                            alpha: 0.04 * _fadeIn.value,
                                          ),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.45, 1.0],
                                      ),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/logo2.png',
                                    width: logoSize,
                                    height: logoSize,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.medium,
                                    cacheWidth: imageCachePx(context, logoSize),
                                    cacheHeight: imageCachePx(
                                      context,
                                      logoSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _riseIn.value * 0.6),
                          child: Column(
                            children: [
                              Text(
                                l10n.appTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppFonts.fraunces,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                  color: const Color(0xFF2A221C),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.appBrandTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                  color: AppThemeColors.lightSeed.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(
                        opacity: (_fadeIn.value * 1.15).clamp(0.0, 1.0),
                        child: AppProgressIndicator(
                          size: 30,
                          strokeWidth: 2.8,
                          color: AppThemeColors.lightSeed.withValues(
                            alpha: 0.85,
                          ),
                          trackColor: AppThemeColors.lightSeed.withValues(
                            alpha: 0.14,
                          ),
                        ),
                      ),
                      const Spacer(flex: 4),
                      Opacity(
                        opacity: _fadeIn.value,
                        child: Text(
                          l10n.splashOrganizationName,
                          style: TextStyle(
                            fontFamily: AppFonts.fraunces,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5C534C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
