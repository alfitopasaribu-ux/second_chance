import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:second_chance/core/constants/app_constants.dart';
// ignore: unused_import
import '../core/constants/app_constants.dart';

// ====================================================
// GLASSMORPHISM CARD
// ====================================================
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? borderColor;
  final double borderRadius;
  final double opacity;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderColor,
    this.borderRadius = 16,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          // ignore: deprecated_member_use
          color: (borderColor ?? AppColors.primary).withOpacity(0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: (borderColor ?? AppColors.primary).withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -2,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ====================================================
// NEON BUTTON
// ====================================================
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool isLoading;
  final IconData? icon;
  final double width;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = AppColors.primary,
    this.isLoading = false,
    this.icon,
    this.width = double.infinity,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) => GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width,
          height: 52,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: widget.color.withOpacity(0.6 + _pulseController.value * 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: widget.color.withOpacity(0.2 + _pulseController.value * 0.15),
                blurRadius: 16 + _pulseController.value * 8,
                spreadRadius: -2,
              ),
            ],
          ),
          child: widget.isLoading
              ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: widget.color, strokeWidth: 2)))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.color, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ====================================================
// CYBER INPUT FIELD
// ====================================================
class CyberTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final int maxLines;
  final void Function(String)? onChanged;

  const CyberTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 12, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
          ),
        ),
      ],
    );
  }
}

// ====================================================
// FLOATING PARTICLES BACKGROUND
// ====================================================
class ParticleBackground extends StatefulWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Particle> _particles;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(15, (_) => Particle(_rand));
    _controllers = _particles.map((p) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(seconds: 4 + _rand.nextInt(6)),
      )..repeat(reverse: true);
      return ctrl;
    }).toList();
  }

  @override
  void dispose() {
    // ignore: curly_braces_in_flow_control_structures
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.3, -0.5),
              radius: 1.2,
              colors: [Color(0xFF0D1B2E), AppColors.bgDark, Color(0xFF030812)],
            ),
          ),
        ),
        // Particles
        ...List.generate(_particles.length, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, __) {
              final p = _particles[i];
              return Positioned(
                left: p.x * MediaQuery.of(context).size.width,
                top: p.y * MediaQuery.of(context).size.height + _controllers[i].value * 30 - 15,
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // ignore: deprecated_member_use
                    color: p.color.withOpacity(0.3 + _controllers[i].value * 0.4),
                    boxShadow: [
                      // ignore: deprecated_member_use
                      BoxShadow(color: p.color.withOpacity(0.4), blurRadius: p.size * 2),
                    ],
                  ),
                ),
              );
            },
          );
        }),
        widget.child,
      ],
    );
  }
}

class Particle {
  late double x, y, size;
  late Color color;

  Particle(Random rand) {
    x = rand.nextDouble();
    y = rand.nextDouble();
    size = 2 + rand.nextDouble() * 4;
    final colors = [AppColors.primary, AppColors.secondary, AppColors.glowPink, AppColors.glowGreen];
    color = colors[rand.nextInt(colors.length)];
  }
}

// ====================================================
// EMOTIONAL SCORE BAR
// ====================================================
class EmotionalScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;

  const EmotionalScoreBar({
    super.key,
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('$score', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.bgCardLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: score / 100,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  gradient: LinearGradient(colors: [color.withOpacity(0.6), color]),
                  borderRadius: BorderRadius.circular(3),
                  // ignore: deprecated_member_use
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
            ).animate().slideX(begin: -1, duration: 800.ms, curve: Curves.easeOutCubic),
          ],
        ),
      ],
    );
  }
}
