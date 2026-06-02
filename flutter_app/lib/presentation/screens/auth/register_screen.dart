import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok!'), backgroundColor: AppColors.accent),
      );
      return;
    }
    final success = await ref.read(authProvider.notifier).register(
      _usernameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text,
    );
    if (success && mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'DAFTAR AKUN',
                      style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 20,
                        fontWeight: FontWeight.w700, letterSpacing: 2,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 36),
                  child: Text(
                    'Mulai perjalanan emosionalmu',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CyberTextField(
                          label: 'USERNAME',
                          hint: 'nama_kamu',
                          controller: _usernameCtrl,
                          prefixIcon: Icons.person_outline,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Username wajib diisi';
                            if (v!.length < 3) return 'Minimal 3 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CyberTextField(
                          label: 'EMAIL',
                          hint: 'email@kamu.com',
                          controller: _emailCtrl,
                          prefixIcon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Email wajib diisi';
                            if (!v!.contains('@')) return 'Email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CyberTextField(
                          label: 'PASSWORD',
                          hint: 'Minimal 6 karakter',
                          controller: _passCtrl,
                          obscureText: _obscure,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Password wajib diisi';
                            if (v!.length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CyberTextField(
                          label: 'KONFIRMASI PASSWORD',
                          hint: 'Ulangi password',
                          controller: _confirmPassCtrl,
                          obscureText: _obscure,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => v?.isEmpty == true ? 'Wajib diisi' : null,
                        ),

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

                        if (auth.error != null) ...[
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
                                Expanded(child: Text(auth.error!, style: const TextStyle(color: AppColors.accent, fontSize: 13))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        NeonButton(
                          label: 'BUAT AKUN',
                          onPressed: _register,
                          isLoading: auth.isLoading,
                          icon: Icons.rocket_launch,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? ', style: TextStyle(color: AppColors.textMuted)),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'MASUK',
                        style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
