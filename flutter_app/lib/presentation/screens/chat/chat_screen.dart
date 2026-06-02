import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/shared_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/api_service_provider.dart';
import '../../../core/providers/auth_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String scenarioId;
  final String scenarioTitle;
  final String category;
  final String emotionalGoal;

  const ChatScreen({
    super.key,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.category,
    required this.emotionalGoal,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  // ignore: prefer_final_fields
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isSending = false;
  String? _conversationId;
  late AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
    _initConversation();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _typingController.dispose();
    super.dispose();
  }

  Future<void> _initConversation() async {
    try {
      final api = ref.read(apiServiceProvider);
      
      // Jika template (bukan custom scenario), buat conversation langsung
      final scenarioId = widget.scenarioId.startsWith('template_')
          ? null
          : widget.scenarioId;

      if (scenarioId == null) {
        // Buat scenario dahulu untuk template
        final scenario = await api.createScenario({
          'title': widget.scenarioTitle,
          'category': widget.category,
          'emotional_goal': widget.emotionalGoal,
        });
        final conv = await api.createConversation(scenario['id'], 'Sesi: ${widget.scenarioTitle}');
        setState(() => _conversationId = conv['id']);
      } else {
        final conv = await api.createConversation(scenarioId, 'Sesi: ${widget.scenarioTitle}');
        setState(() => _conversationId = conv['id']);
      }

      // Pesan pembuka AI
      _addAIIntroMessage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai sesi: $e'), backgroundColor: AppColors.accent),
        );
      }
    }
  }

  void _addAIIntroMessage() {
    final Map<String, String> intros = {
      'meminta_maaf': 'Kamu mau ngomong apa sama aku? Aku lagi dengerin...',
      'confession': 'Ada yang mau kamu ceritakan? Aku di sini.',
      'interview_kerja': 'Baik, mari kita mulai. Ceritakan tentang dirimu terlebih dahulu.',
      'bicara_orang_tua': 'Ada apa, Nak? Kamu terlihat ingin membicarakan sesuatu.',
      'toxic_friend': 'Eh, lama juga ya kita nggak ngobrol. Kenapa tiba-tiba hubungi aku?',
      'breakup': '...',
      'public_speaking': 'Silakan, kami siap mendengarkan presentasimu.',
      'komunikasi_emosional': 'Aku di sini. Ceritakan apa yang ada di pikiranmu.',
    };

    final intro = intros[widget.category] ?? 'Aku siap. Apa yang ingin kamu sampaikan?';

    setState(() {
      _messages.add({
        'sender': 'ai',
        'message': intro,
        'emotional_tone': 'neutral',
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending || _conversationId == null) return;

    _msgCtrl.clear();

    setState(() {
      _messages.add({
        'sender': 'user',
        'message': text,
        'emotional_tone': 'neutral',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _isSending = true;
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.sendMessage(
        conversationId: _conversationId!,
        message: text,
        category: widget.category,
        scenarioContext: widget.emotionalGoal,
        messageHistory: _messages.take(_messages.length - 1).toList(),
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _isSending = false;
          _messages.add({
            'sender': 'ai',
            'message': response['message'] ?? '',
            'emotional_tone': response['emotional_tone'] ?? 'neutral',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _isSending = false;
          _messages.add({
            'sender': 'ai',
            'message': 'Maaf, aku sedang tidak bisa merespons sekarang...',
            'emotional_tone': 'confused',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getToneColor(String tone) {
    switch (tone) {
      case 'angry': return AppColors.toneAngry;
      case 'sad': return AppColors.toneSad;
      case 'happy': return AppColors.toneHappy;
      case 'anxious': return AppColors.toneAnxious;
      case 'disappointed': return AppColors.toneDisappointed;
      case 'confused': return AppColors.toneConfused;
      default: return AppColors.primary;
    }
  }

  String _getToneLabel(String tone) {
    switch (tone) {
      case 'angry': return 'Marah';
      case 'sad': return 'Sedih';
      case 'happy': return 'Senang';
      case 'anxious': return 'Cemas';
      case 'disappointed': return 'Kecewa';
      case 'confused': return 'Bingung';
      default: return 'Netral';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final username = auth.user?['username'] ?? 'Kamu';

    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.bgCard.withOpacity(0.8),
                  // ignore: deprecated_member_use
                  border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.2))),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/scenario'),
                      child: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    // AI Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.secondary, width: 1.5),
                        // ignore: deprecated_member_use
                        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12)],
                        gradient: const RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgDark]),
                      ),
                      child: const Center(child: Text('AI', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.scenarioTitle, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(_isTyping ? 'sedang mengetik...' : 'Online', style: TextStyle(color: _isTyping ? AppColors.glowGreen : AppColors.primary, fontSize: 11)),
                        ],
                      ),
                    ),
                    // Analyze button
                    if (_messages.length > 2)
                      GestureDetector(
                        onTap: _conversationId != null
                            ? () => context.go('/analysis', extra: {'conversation_id': _conversationId})
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: AppColors.glowPink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            // ignore: deprecated_member_use
                            border: Border.all(color: AppColors.glowPink.withOpacity(0.4)),
                          ),
                          child: const Text('ANALISIS', style: TextStyle(color: AppColors.glowPink, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ),
                      ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _messages.length && _isTyping) {
                            return _TypingIndicator(controller: _typingController);
                          }
                          final msg = _messages[i];
                          final isUser = msg['sender'] == 'user';
                          return _MessageBubble(
                            message: msg['message'] ?? '',
                            isUser: isUser,
                            username: username,
                            emotionalTone: msg['emotional_tone'] ?? 'neutral',
                            toneColor: _getToneColor(msg['emotional_tone'] ?? 'neutral'),
                            toneLabel: _getToneLabel(msg['emotional_tone'] ?? 'neutral'),
                            index: i,
                          );
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: AppColors.bgCard.withOpacity(0.9),
                  // ignore: deprecated_member_use
                  border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.2))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(24),
                          // ignore: deprecated_member_use
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: _msgCtrl,
                          maxLines: null,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Ketik pesanmu...',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: AnimatedBuilder(
                        animation: _typingController,
                        builder: (_, __) => Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // ignore: prefer_const_constructors
                            gradient: LinearGradient(
                              // ignore: prefer_const_literals_to_create_immutables
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            // ignore: deprecated_member_use
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16)],
                          ),
                          child: const Icon(Icons.send, color: AppColors.bgDark, size: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String username;
  final String emotionalTone;
  final Color toneColor;
  final String toneLabel;
  final int index;

  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.username,
    required this.emotionalTone,
    required this.toneColor,
    required this.toneLabel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: toneColor, width: 1.5),
                // ignore: deprecated_member_use
                boxShadow: [BoxShadow(color: toneColor.withOpacity(0.3), blurRadius: 8)],
                gradient: const RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgDark]),
              ),
              child: const Center(child: Text('AI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.secondary))),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: isUser ? AppColors.primary.withOpacity(0.15) : AppColors.bgCardLight,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: isUser ? AppColors.primary.withOpacity(0.4) : toneColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: (isUser ? AppColors.primary : toneColor).withOpacity(0.08),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5),
                  ),
                ),
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: toneColor),
                      ),
                      const SizedBox(width: 4),
                      Text(toneLabel, style: TextStyle(color: toneColor, fontSize: 10, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ],
            // ignore: prefer_const_constructors
            ).animate(delay: Duration(milliseconds: 50)).fadeIn().slideY(begin: 0.1),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1.5),
                gradient: const RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgDark]),
              ),
              child: Center(
                child: Text(username[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final AnimationController controller;
  const _TypingIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary),
              gradient: const RadialGradient(colors: [AppColors.bgCardLight, AppColors.bgDark]),
            ),
            child: const Center(child: Text('AI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.secondary))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgCardLight,
              borderRadius: BorderRadius.circular(16),
              // ignore: deprecated_member_use
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: AnimatedBuilder(
              animation: controller,
              builder: (_, __) => Row(
                children: List.generate(3, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6 + controller.value * 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: AppColors.secondary.withOpacity(0.5 + controller.value * 0.5),
                  ),
                )),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
