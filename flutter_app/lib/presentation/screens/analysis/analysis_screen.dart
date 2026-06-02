import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_service_provider.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const AnalysisScreen({super.key, required this.conversationId});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _feedback;
  bool _isLoading = true;
  // ignore: unused_field
  bool _isAnalyzing = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _analyze();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    setState(() { _isLoading = true; _isAnalyzing = true; });
    try {
      final api = ref.read(apiServiceProvider);
      final feedback = await api.analyzeConversation(widget.conversationId);
      if (mounted) setState(() { _feedback = feedback; _isLoading = false; _isAnalyzing = false; });
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _isAnalyzing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ANALISIS EMOSI', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2)),
                        Text('Hasil evaluasi AI', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _feedback == null
                        ? _buildErrorState()
                        : _buildResultState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
                boxShadow: [
                  // ignore: deprecated_member_use
                  BoxShadow(color: AppColors.secondary.withOpacity(0.3 + _glowController.value * 0.3), blurRadius: 30),
                ],
              ),
              child: const Center(child: Icon(Icons.psychology, color: AppColors.secondary, size: 48)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('MENGANALISIS PERCAKAPAN...', style: TextStyle(color: AppColors.primary, fontSize: 13, letterSpacing: 3)),
          const SizedBox(height: 8),
          const Text('AI sedang mengevaluasi komunikasimu', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 24),
          // ignore: prefer_const_constructors
          SizedBox(
            width: 200,
            // ignore: prefer_const_constructors
            child: LinearProgressIndicator(color: AppColors.secondary, backgroundColor: AppColors.bgCardLight, minHeight: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.accent, size: 48),
            const SizedBox(height: 16),
            const Text('Gagal menganalisis', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 16),
            NeonButton(label: 'COBA LAGI', onPressed: _analyze, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildResultState() {
    final f = _feedback!;
    final overall = f['overall_score'] as int? ?? 0;
    final strengths = (f['strengths'] as List?)?.cast<String>() ?? [];
    final improvements = (f['improvements'] as List?)?.cast<String>() ?? [];

    Color overallColor = overall >= 80 ? AppColors.glowGreen : overall >= 60 ? AppColors.glowBlue : AppColors.glowPink;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Overall Score Circle
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: overallColor, width: 2),
                boxShadow: [
                  // ignore: deprecated_member_use
                  BoxShadow(color: overallColor.withOpacity(0.2 + _glowController.value * 0.2), blurRadius: 30 + _glowController.value * 15),
                ],
                // ignore: deprecated_member_use
                gradient: RadialGradient(colors: [overallColor.withOpacity(0.1), AppColors.bgDark]),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$overall', style: TextStyle(color: overallColor, fontSize: 48, fontWeight: FontWeight.w900)),
                  // ignore: deprecated_member_use
                  Text('/100', style: TextStyle(color: overallColor.withOpacity(0.7), fontSize: 14)),
                ],
              ),
            ),
          ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),

          const SizedBox(height: 8),
          const Text('SKOR KESELURUHAN', style: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 3)),

          const SizedBox(height: 28),

          // Score Bars
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BREAKDOWN SKOR', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
                const SizedBox(height: 20),
                EmotionalScoreBar(label: 'Empati', score: f['empathy_score'] as int? ?? 0, color: AppColors.toneSad),
                const SizedBox(height: 14),
                EmotionalScoreBar(label: 'Kejujuran', score: f['honesty_score'] as int? ?? 0, color: AppColors.glowGreen),
                const SizedBox(height: 14),
                EmotionalScoreBar(label: 'Kepercayaan Diri', score: f['confidence_score'] as int? ?? 0, color: AppColors.primary),
                const SizedBox(height: 14),
                EmotionalScoreBar(label: 'Ketegangan', score: f['tension_score'] as int? ?? 0, color: AppColors.toneAngry),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Feedback Text
          if (f['feedback_text'] != null)
            GlassCard(
              borderColor: AppColors.secondary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ignore: prefer_const_constructors
                  Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const Icon(Icons.psychology, color: AppColors.secondary, size: 18),
                      const SizedBox(width: 8),
                      const Text('EVALUASI AI', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(f['feedback_text'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.6)),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 16),

          // Strengths & Improvements
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  borderColor: AppColors.glowGreen,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('KEKUATAN', style: TextStyle(color: AppColors.glowGreen, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      ...strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✓ ', style: TextStyle(color: AppColors.glowGreen, fontSize: 12)),
                            Expanded(child: Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  borderColor: AppColors.glowPink,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PERBAIKAN', style: TextStyle(color: AppColors.glowPink, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
                      const SizedBox(height: 10),
                      ...improvements.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('→ ', style: TextStyle(color: AppColors.glowPink, fontSize: 12)),
                            Expanded(child: Text(s, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 24),

          // Action Buttons
          NeonButton(
            label: 'COBA LAGI',
            onPressed: () => context.go('/scenario'),
            color: AppColors.secondary,
            icon: Icons.replay,
          ).animate().fadeIn(delay: 900.ms),

          const SizedBox(height: 12),

          NeonButton(
            label: 'KE DASHBOARD',
            onPressed: () => context.go('/dashboard'),
            color: AppColors.primary,
            icon: Icons.home,
          ).animate().fadeIn(delay: 1000.ms),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
