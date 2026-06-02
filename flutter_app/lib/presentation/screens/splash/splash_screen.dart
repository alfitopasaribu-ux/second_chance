import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final auth = ref.read(authProvider);

    if (auth.isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              AnimatedBuilder(
                animation: _glowController,
                builder: (_, __) => Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(
                          0.3 + (_glowController.value * 0.3),
                        ),
                        blurRadius: 30 + (_glowController.value * 20),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.secondary.withOpacity(
                          0.2 + (_glowController.value * 0.2),
                        ),
                        blurRadius: 50 + (_glowController.value * 20),
                        spreadRadius: -5,
                      ),
                    ],
                    gradient: const RadialGradient(
                      colors: [
                        AppColors.bgCardLight,
                        AppColors.bgDark,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'SC',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ).animate().scale(
                    begin: const Offset(0, 0),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 32),

              // TITLE
              const Text(
                'SECOND CHANCE',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 600.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 8),

              // SUBTITLE
              const Text(
                'AI Emotional Simulator',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(
                    delay: 700.ms,
                    duration: 600.ms,
                  ),

              const SizedBox(height: 4),

              const Text(
                'Berlatih. Merasakan. Berkembang.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(
                    delay: 900.ms,
                    duration: 600.ms,
                  ),

              const SizedBox(height: 60),

              // LOADING
              const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.bgCardLight,
                  color: AppColors.primary,
                  minHeight: 2,
                ),
              ).animate().fadeIn(
                    delay: 1200.ms,
                    duration: 400.ms,
                  ),

              const SizedBox(height: 16),

              const Text(
                'MEMUAT SISTEM...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 1400.ms),
            ],
          ),
        ),
      ),
    );
  }
}