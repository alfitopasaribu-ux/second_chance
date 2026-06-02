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

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authProvider);
      if (auth.isCheckingAuth) {
        ref.listen<AuthState>(authProvider, (prev, next) {
          if (!mounted) return;
          if (!next.isCheckingAuth) {
            context.go(next.isAuthenticated ? '/dashboard' : '/login');
          }
        });
      } else {
        context.go(auth.isAuthenticated ? '/dashboard' : '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: ParticleBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                  // ignore: prefer_const_constructors
                  gradient: RadialGradient(
                    // ignore: prefer_const_literals_to_create_immutables
                    colors: [AppColors.bgCardLight, AppColors.bgDark],
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
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 24),
              const Text(
                'SECOND CHANCE',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 10),
              const Text(
                'AI Emotional Simulator',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 16),
              if (auth.isCheckingAuth) ...[
                const SizedBox(height: 12),
                const SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.bgCardLight,
                    color: AppColors.primary,
                    minHeight: 2,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                const SizedBox(height: 10),
                const Text(
                  'MEMUAT SISTEM...',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

