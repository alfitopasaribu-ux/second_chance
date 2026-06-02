import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
    if (success && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                          boxShadow: [
                            // ignore: deprecated_member_use
                            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20),
                          ],
                          gradient: const RadialGradient(
                            colors: [AppColors.bgCardLight, AppColors.bgDark],
                          ),
                        ),
                        child: const Center(
                          child: Text('SC', style: TextStyle(
                            color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.w900,
                          )),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),

                      const Text(
                        'SECOND CHANCE',
                        style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 22,
                          fontWeight: FontWeight.w900, letterSpacing: 3,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 4),
                      const Text(
                        'Masuk ke duniamu',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13, letterSpacing: 1),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login Form Card
                  GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MASUK',
                            style: TextStyle(
                              color: AppColors.primary, fontSize: 13,
                              fontWeight: FontWeight.w700, letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 24),

                          CyberTextField(
                            label: 'EMAIL',
                            hint: 'email@kamu.com',
                            controller: _emailCtrl,
                            prefixIcon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v?.isEmpty == true ? 'Email wajib diisi' : null,
                          ),

                          const SizedBox(height: 20),

                          CyberTextField(
                            label: 'PASSWORD',
                            hint: '••••••••',
                            controller: _passCtrl,
                            obscureText: _obscure,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) => v?.isEmpty == true ? 'Password wajib diisi' : null,
                          ),

                          // Toggle password visibility
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              child: Text(
                                _obscure ? 'LIHAT PASSWORD' : 'SEMBUNYIKAN',
                                style: const TextStyle(color: AppColors.primary, fontSize: 11, letterSpacing: 1),
                              ),
                            ),
                          ),

                          // Error message
                          if (auth.error != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                // ignore: deprecated_member_use
                                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.accent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(auth.error!, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          NeonButton(
                            label: 'MASUK',
                            onPressed: _login,
                            isLoading: auth.isLoading,
                            icon: Icons.login,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? ', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'DAFTAR',
                          style: TextStyle(
                            color: AppColors.primary, fontSize: 14,
                            fontWeight: FontWeight.w700, letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 40),

                  const Text(
                    '© 2045 SECOND CHANCE AI',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 2),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
