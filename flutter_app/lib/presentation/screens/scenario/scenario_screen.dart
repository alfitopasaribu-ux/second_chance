import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_service_provider.dart';

class ScenarioScreen extends ConsumerStatefulWidget {
  const ScenarioScreen({super.key});

  @override
  ConsumerState<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends ConsumerState<ScenarioScreen> {
  List<dynamic> _userScenarios = [];
  // ignore: unused_field
  bool _isLoading = true;
  bool _showCreateForm = false;

  final _titleCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  String _selectedCategory = 'komunikasi_emosional';
  int _selectedDifficulty = 1;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadScenarios() async {
    try {
      final api = ref.read(apiServiceProvider);
      final scenarios = await api.getScenarios();
      if (mounted) setState(() { _userScenarios = scenarios; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createScenario() async {
    if (_titleCtrl.text.isEmpty || _goalCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan tujuan wajib diisi!'), backgroundColor: AppColors.accent),
      );
      return;
    }
    try {
      final api = ref.read(apiServiceProvider);
      await api.createScenario({
        'title': _titleCtrl.text,
        'category': _selectedCategory,
        'emotional_goal': _goalCtrl.text,
        'difficulty_level': _selectedDifficulty,
      });
      _titleCtrl.clear();
      _goalCtrl.clear();
      setState(() => _showCreateForm = false);
      _loadScenarios();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat skenario: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  void _startChat(Map<String, dynamic> scenario) {
    context.go('/chat', extra: {
      'scenario_id': scenario['id'],
      'title': scenario['title'],
      'category': scenario['category'],
      'emotional_goal': scenario['emotional_goal'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
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
                        Text('SKENARIO', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2)),
                        Text('Pilih atau buat skenario latihan', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showCreateForm = !_showCreateForm),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          // ignore: deprecated_member_use
                          border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                        ),
                        child: Icon(
                          _showCreateForm ? Icons.close : Icons.add,
                          color: AppColors.secondary, size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Create Form
                      if (_showCreateForm) ...[
                        GlassCard(
                          borderColor: AppColors.secondary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('BUAT SKENARIO BARU', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
                              const SizedBox(height: 16),
                              CyberTextField(label: 'JUDUL SKENARIO', hint: 'Contoh: Minta Maaf ke Sahabat', controller: _titleCtrl),
                              const SizedBox(height: 14),
                              const Text('KATEGORI', style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 1.5)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                // ignore: deprecated_member_use
                                value: _selectedCategory,
                                dropdownColor: AppColors.bgCard,
                                style: const TextStyle(color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.bgCardLight,
                                  // ignore: deprecated_member_use
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                  // ignore: deprecated_member_use
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
                                ),
                                items: AppConstants.scenarioCategories.map((cat) {
                                  return DropdownMenuItem<String>(
                                    value: cat['key'] as String,
                                    child: Text('${cat['icon']} ${cat['title']}'),
                                  );
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v!),
                              ),
                              const SizedBox(height: 14),
                              CyberTextField(
                                label: 'TUJUAN EMOSIONAL',
                                hint: 'Apa yang ingin kamu capai dari latihan ini?',
                                controller: _goalCtrl,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),
                              const Text('TINGKAT KESULITAN', style: TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 1.5)),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  final level = i + 1;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedDifficulty = level),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        // ignore: deprecated_member_use
                                        color: _selectedDifficulty == level ? AppColors.secondary.withOpacity(0.3) : AppColors.bgCardLight,
                                        borderRadius: BorderRadius.circular(6),
                                        // ignore: deprecated_member_use
                                        border: Border.all(color: _selectedDifficulty == level ? AppColors.secondary : AppColors.textMuted.withOpacity(0.3)),
                                      ),
                                      child: Text('$level', style: TextStyle(color: _selectedDifficulty == level ? AppColors.secondary : AppColors.textMuted)),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 20),
                              NeonButton(label: 'BUAT SKENARIO', onPressed: _createScenario, color: AppColors.secondary, icon: Icons.add),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
                        const SizedBox(height: 20),
                      ],

                      // Built-in Templates
                      const Text('TEMPLATE SKENARIO', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
                      const SizedBox(height: 12),

                      ...AppConstants.scenarioCategories.asMap().entries.map((entry) {
                        final i = entry.key;
                        final cat = entry.value;
                        return GestureDetector(
                          onTap: () {
                            context.go('/chat', extra: {
                              'scenario_id': 'template_${cat['key']}',
                              'title': cat['title'],
                              'category': cat['key'],
                              'emotional_goal': cat['description'],
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              borderColor: cat['color'] as Color,
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: (cat['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(child: Text(cat['icon'] as String, style: const TextStyle(fontSize: 22))),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cat['title'] as String, style: TextStyle(color: cat['color'] as Color, fontSize: 14, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(cat['description'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 12), maxLines: 2),
                                      ],
                                    ),
                                  ),
                                  // ignore: deprecated_member_use
                                  Icon(Icons.play_circle_fill, color: (cat['color'] as Color).withOpacity(0.7), size: 28),
                                ],
                              ),
                            ),
                          ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideX(begin: 0.1),
                        );
                      }),

                      // User Custom Scenarios
                      if (_userScenarios.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text('SKENARIO KUSTOM', style: TextStyle(color: AppColors.glowGreen, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
                        const SizedBox(height: 12),
                        ..._userScenarios.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GlassCard(
                            borderColor: AppColors.glowGreen,
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, color: AppColors.glowGreen, size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s['title'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                      Text(s['category'], style: const TextStyle(color: AppColors.glowGreen, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _startChat(s),
                                  child: const Icon(Icons.play_circle_fill, color: AppColors.glowGreen, size: 28),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final api = ref.read(apiServiceProvider);
                                    await api.deleteScenario(s['id']);
                                    _loadScenarios();
                                  },
                                  child: const Icon(Icons.delete_outline, color: AppColors.accent, size: 20),
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
            ],
          ),
        ),
      ),
    );
  }
}
