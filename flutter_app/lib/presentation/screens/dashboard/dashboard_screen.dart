import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/api_service_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<dynamic> _recentConversations = [];
  List<dynamic> _scenarios = [];
  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ref.read(apiServiceProvider);
      final conversations = await api.getConversations();
      final scenarios = await api.getScenarios();
      if (mounted) {
        setState(() {
          _recentConversations = conversations.take(3).toList();
          _scenarios = scenarios;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final username = auth.user?['username'] ?? 'Pengguna';

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            backgroundColor: AppColors.bgCard,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ignore: prefer_const_constructors
                          Text(
                            'Selamat Datang,',
                            // ignore: prefer_const_constructors
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13, letterSpacing: 1),
                          ),
                          Text(
                            username,
                            style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 22,
                              fontWeight: FontWeight.w700, letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context.go('/history'),
                            child: const Icon(Icons.history, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () => context.go('/profile'),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 1.5),
                                // ignore: deprecated_member_use
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12)],
                              ),
                              child: Center(
                                child: Text(
                                  username[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  // Tagline
                  const Text(
                    'SECOND CHANCE AI • EMOTIONAL SIMULATOR',
                    style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 28),

                  // Quick Stats
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.layers,
                        label: 'Skenario',
                        value: _scenarios.length.toString(),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.chat_bubble_outline,
                        label: 'Percakapan',
                        value: _recentConversations.length.toString(),
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.psychology,
                        label: 'Analisis',
                        value: _recentConversations.where((c) => c['is_completed'] == true).length.toString(),
                        color: AppColors.glowPink,
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 28),

                  // Hero Action
                  GlassCard(
                    borderColor: AppColors.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mulai Sesi Baru',
                                  style: TextStyle(
                                    color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'AI siap menjadi lawan bicaramu',
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        NeonButton(
                          label: 'PILIH SKENARIO',
                          onPressed: () => context.go('/scenario'),
                          color: AppColors.secondary,
                          icon: Icons.play_arrow,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // Scenario Categories Grid
                  const Text(
                    'KATEGORI LATIHAN',
                    style: TextStyle(
                      color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3,
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: AppConstants.scenarioCategories.length,
                    itemBuilder: (_, i) {
                      final cat = AppConstants.scenarioCategories[i];
                      return GestureDetector(
                        onTap: () => context.go('/scenario'),
                        child: GlassCard(
                          borderColor: cat['color'] as Color,
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(cat['icon'] as String, style: const TextStyle(fontSize: 24)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat['title'] as String,
                                    style: TextStyle(
                                      color: (cat['color'] as Color),
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ).animate(delay: Duration(milliseconds: 500 + i * 60)).fadeIn().slideY(begin: 0.3),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Recent Conversations
                  if (_recentConversations.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RIWAYAT TERBARU',
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/history'),
                          child: const Text('LIHAT SEMUA', style: TextStyle(color: AppColors.secondary, fontSize: 10, letterSpacing: 1)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 12),

                    ..._recentConversations.map((conv) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conv['session_title'] ?? 'Sesi Percakapan',
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    conv['scenario_title'] ?? '',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (conv['is_completed'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: AppColors.glowGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  // ignore: deprecated_member_use
                                  border: Border.all(color: AppColors.glowGreen.withOpacity(0.3)),
                                ),
                                child: const Text('SELESAI', style: TextStyle(color: AppColors.glowGreen, fontSize: 9, letterSpacing: 1)),
                              ),
                          ],
                        ),
                      ),
                    )),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        borderColor: color,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
