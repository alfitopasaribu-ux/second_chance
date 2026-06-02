// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/scenario/scenario_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/analysis/analysis_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/scenario', builder: (_, __) => const ScenarioScreen()),
      GoRoute(
        path: '/chat',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ChatScreen(
            scenarioId: extra?['scenario_id'] ?? '',
            scenarioTitle: extra?['title'] ?? '',
            category: extra?['category'] ?? '',
            emotionalGoal: extra?['emotional_goal'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/analysis',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AnalysisScreen(conversationId: extra?['conversation_id'] ?? '');
        },
      ),
      GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});
