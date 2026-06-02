import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_service_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _glowController;
  int _totalScenarios = 0;
  int _totalConversations = 0;
  int _completedConversations = 0;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadStats();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final api = ref.read(apiServiceProvider);
      final scenarios = await api.getScenarios();
      final conversations = await api.getConversations();
      if (mounted) {
        setState(() {
          _totalScenarios = scenarios.length;
          _totalConversations = conversations.length;
          _completedConversations = conversations.where((c) => c['is_completed'] == true).length;
        });
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          // ignore: deprecated_member_use
          side: BorderSide(color: AppColors.accent.withOpacity(0.4)),
        ),
        title: const Text('Keluar?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Kamu akan keluar dari Second Chance.', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final username = user?['username'] ?? 'Pengguna';
    final email = user?['email'] ?? '';

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('PROFIL', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2)),
                  ],
                ).animate().fadeIn(),

                const SizedBox(height: 32),

                // Avatar
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (_, __) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.primary.withOpacity(0.2 + _glowController.value * 0.2),
                          blurRadius: 24 + _glowController.value * 12,
                        ),
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: AppColors.secondary.withOpacity(0.1 + _glowController.value * 0.1),
                          blurRadius: 40,
                        ),
                      ],
                      gradient: const RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgDark]),
                    ),
                    child: Center(
                      child: Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontSize: 42, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 16),

                Text(username, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    // ignore: deprecated_member_use
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Text('EMOTIONAL TRAINER', style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // Stats Grid
                Row(
                  children: [
                    _ProfileStat(label: 'Skenario', value: '$_totalScenarios', icon: Icons.layers, color: AppColors.primary),
                    const SizedBox(width: 12),
                    _ProfileStat(label: 'Percakapan', value: '$_totalConversations', icon: Icons.chat_bubble_outline, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    _ProfileStat(label: 'Selesai', value: '$_completedConversations', icon: Icons.check_circle_outline, color: AppColors.glowGreen),
                  ],
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 28),

                // Menu Items
                GlassCard(
                  child: Column(
                    children: [
                      _MenuItem(icon: Icons.layers, label: 'Skenario Saya', color: AppColors.primary, onTap: () => context.go('/scenario')),
                      _Divider(),
                      _MenuItem(icon: Icons.history, label: 'Riwayat Percakapan', color: AppColors.secondary, onTap: () => context.go('/history')),
                      _Divider(),
                      _MenuItem(icon: Icons.psychology, label: 'Lihat Analisis', color: AppColors.glowPink, onTap: () => context.go('/history')),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),

                // App Info
                GlassCard(
                  child: Column(
                    children: [
                      _MenuItem(icon: Icons.info_outline, label: 'Tentang Aplikasi', color: AppColors.textMuted, onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.bgCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Second Chance', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            content: const Text(
                              'AI Emotional Conversation Simulator\nVersi 1.0.0\n\nDibuat dengan Flutter + Groq AI\n\n© 2045 Second Chance AI',
                              style: TextStyle(color: AppColors.textSecondary, height: 1.6),
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.primary))),
                            ],
                          ),
                        );
                      }),
                      _Divider(),
                      _MenuItem(
                        icon: Icons.logout,
                        label: 'Keluar',
                        color: AppColors.accent,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 32),

                const Text('SECOND CHANCE AI • v1.0.0 • 2045', style: TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 2)).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        borderColor: color,
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
            // ignore: prefer_const_constructors
            Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Divider(color: AppColors.primary.withOpacity(0.1), height: 1);
  }
}
