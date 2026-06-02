// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD

=======
import '../../presentation/screens/splash/splash_screen.dart';
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/scenario/scenario_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/analysis/analysis_screen.dart';
import '../../presentation/screens/history/history_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
<<<<<<< HEAD

=======
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
<<<<<<< HEAD
    debugLogDiagnostics: true,

    // LANGSUNG KE LOGIN
    initialLocation: '/login',

    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // BELUM LOGIN → PAKSA KE LOGIN
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // SUDAH LOGIN → JANGAN BALIK KE LOGIN
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      // LOGIN
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // REGISTER
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // DASHBOARD
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),

      // SCENARIO
      GoRoute(
        path: '/scenario',
        builder: (context, state) => const ScenarioScreen(),
      ),

      // CHAT AI
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

=======
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
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
          return ChatScreen(
            scenarioId: extra?['scenario_id'] ?? '',
            scenarioTitle: extra?['title'] ?? '',
            category: extra?['category'] ?? '',
            emotionalGoal: extra?['emotional_goal'] ?? '',
          );
        },
      ),
<<<<<<< HEAD

      // ANALYSIS
      GoRoute(
        path: '/analysis',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;

          return AnalysisScreen(
            conversationId: extra?['conversation_id'] ?? '',
          );
        },
      ),

      // HISTORY
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),

      // PROFILE
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});
=======
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
>>>>>>> ba968ea74465efef7597cf98104212157e45199a
