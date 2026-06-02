import 'package:flutter/material.dart';

class AppConstants {
  // ================================================
  // GANTI URL INI DENGAN URL VERCEL KAMU SETELAH DEPLOY
  // Untuk development local: http://localhost:3000
  // ================================================
  static const String baseUrl = 'https://second-chance-zeta.vercel.app';
  // static const String baseUrl = 'http://localhost:3000'; // uncomment untuk dev

  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String scenarioEndpoint = '/api/scenario';
  static const String conversationEndpoint = '/api/conversation';
  static const String aiChatEndpoint = '/api/ai/chat';
  static const String analysisEndpoint = '/api/analysis';

  // Scenario Categories
  static const List<Map<String, dynamic>> scenarioCategories = [
    {
      'key': 'meminta_maaf',
      'title': 'Meminta Maaf',
      'icon': '🙏',
      'description': 'Berlatih meminta maaf dengan tulus dan empatik',
      'color': Color(0xFF6C63FF),
    },
    {
      'key': 'confession',
      'title': 'Pengakuan',
      'icon': '💬',
      'description': 'Berani mengungkapkan perasaan atau rahasia',
      'color': Color(0xFFFF6584),
    },
    {
      'key': 'interview_kerja',
      'title': 'Interview Kerja',
      'icon': '💼',
      'description': 'Latihan menghadapi wawancara kerja',
      'color': Color(0xFF43E97B),
    },
    {
      'key': 'bicara_orang_tua',
      'title': 'Bicara dengan Orang Tua',
      'icon': '👨‍👩‍👧',
      'description': 'Komunikasi emosional dengan orang tua',
      'color': Color(0xFFFA709A),
    },
    {
      'key': 'toxic_friend',
      'title': 'Menghadapi Toxic Friend',
      'icon': '⚡',
      'description': 'Berlatih menghadapi teman yang toxic',
      'color': Color(0xFFFF9A9E),
    },
    {
      'key': 'breakup',
      'title': 'Perpisahan',
      'icon': '💔',
      'description': 'Menghadapi atau menyampaikan perpisahan',
      'color': Color(0xFFA18CD1),
    },
    {
      'key': 'public_speaking',
      'title': 'Public Speaking',
      'icon': '🎤',
      'description': 'Latihan berbicara di depan umum',
      'color': Color(0xFF4FACFE),
    },
    {
      'key': 'komunikasi_emosional',
      'title': 'Komunikasi Emosional',
      'icon': '❤️',
      'description': 'Latihan ekspresi emosi yang sehat',
      'color': Color(0xFFFFD700),
    },
  ];
}

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF00D4FF);
  static const Color primaryDark = Color(0xFF0099CC);
  static const Color secondary = Color(0xFF7B2FFF);
  static const Color accent = Color(0xFFFF006E);

  // Background
  static const Color bgDark = Color(0xFF050A18);
  static const Color bgCard = Color(0xFF0D1B2E);
  static const Color bgCardLight = Color(0xFF112240);

  // Glow Colors
  static const Color glowBlue = Color(0xFF00D4FF);
  static const Color glowPurple = Color(0xFF7B2FFF);
  static const Color glowPink = Color(0xFFFF006E);
  static const Color glowGreen = Color(0xFF00FF88);

  // Text
  static const Color textPrimary = Color(0xFFE8F4FD);
  static const Color textSecondary = Color(0xFF8BA3BF);
  static const Color textMuted = Color(0xFF4A6785);

  // Emotional Tones
  static const Color toneAngry = Color(0xFFFF4444);
  static const Color toneSad = Color(0xFF6BA3FF);
  static const Color toneHappy = Color(0xFFFFD700);
  static const Color toneNeutral = Color(0xFF00D4FF);
  static const Color toneAnxious = Color(0xFFFF8C00);
  static const Color toneDisappointed = Color(0xFFA18CD1);
  static const Color toneConfused = Color(0xFF43E97B);
}
