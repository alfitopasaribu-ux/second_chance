import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_service_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(apiServiceProvider);
      final convs = await api.getConversations();
      if (mounted) setState(() { _conversations = convs; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        // ignore: deprecated_member_use
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.accent.withOpacity(0.4))),
        title: const Text('Hapus Percakapan?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Riwayat percakapan ini akan dihapus permanen.', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
    if (confirm == true) {
      final api = ref.read(apiServiceProvider);
      await api.deleteConversation(id);
      _load();
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
                        Text('RIWAYAT', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2)),
                        Text('Semua percakapan kamu', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _conversations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.chat_bubble_outline, color: AppColors.textMuted, size: 64),
                                const SizedBox(height: 16),
                                const Text('Belum ada percakapan', style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
                                const SizedBox(height: 8),
                                const Text('Mulai latihan pertamamu!', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                const SizedBox(height: 24),
                                NeonButton(label: 'MULAI SEKARANG', onPressed: () => context.go('/scenario'), width: 200),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.primary,
                            backgroundColor: AppColors.bgCard,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _conversations.length,
                              itemBuilder: (_, i) {
                                final conv = _conversations[i];
                                final isCompleted = conv['is_completed'] == true;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GlassCard(
                                    borderColor: isCompleted ? AppColors.glowGreen : AppColors.primary,
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            // ignore: deprecated_member_use
                                            color: (isCompleted ? AppColors.glowGreen : AppColors.primary).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            isCompleted ? Icons.check_circle_outline : Icons.chat_bubble_outline,
                                            color: isCompleted ? AppColors.glowGreen : AppColors.primary,
                                            size: 22,
                                          ),
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
                                              const SizedBox(height: 2),
                                              Text(
                                                conv['scenario_title'] ?? '',
                                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.chat, color: AppColors.textMuted, size: 11),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${conv['message_count'] ?? 0} pesan',
                                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                                  ),
                                                  if (isCompleted) ...[
                                                    const SizedBox(width: 10),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            if (isCompleted)
                                              GestureDetector(
                                                onTap: () => context.go('/analysis', extra: {'conversation_id': conv['id']}),
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    // ignore: deprecated_member_use
                                                    color: AppColors.secondary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Icon(Icons.psychology, color: AppColors.secondary, size: 18),
                                                ),
                                              ),
                                            const SizedBox(height: 6),
                                            GestureDetector(
                                              onTap: () => _delete(conv['id']),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  // ignore: deprecated_member_use
                                                  color: AppColors.accent.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: const Icon(Icons.delete_outline, color: AppColors.accent, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
