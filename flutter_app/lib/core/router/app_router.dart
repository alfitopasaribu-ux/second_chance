// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    debugLogDiagnostics: true,

    // APP MULAI DARI LOGIN
    initialLocation: '/login',

    redirect: (context, state) {

      final isLoggedIn =
          authState.isAuthenticated;

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // BELUM LOGIN
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // SUDAH LOGIN
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },

    routes: [

      // LOGIN
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const LoginScreen(),
      ),

      // REGISTER
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            const RegisterScreen(),
      ),

      // DASHBOARD
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const DashboardScreen(),
      ),

      // SCENARIO
      GoRoute(
        path: '/scenario',
        builder: (context, state) =>
            const ScenarioScreen(),
      ),

      // CHAT
      GoRoute(
        path: '/chat',
        builder: (context, state) {

          final extra =
              state.extra as Map<String, dynamic>?;

          return ChatScreen(
            scenarioId:
                extra?['scenario_id'] ?? '',

            scenarioTitle:
                extra?['title'] ?? '',

            category:
                extra?['category'] ?? '',

            emotionalGoal:
                extra?['emotional_goal'] ?? '',
          );
        },
      ),

      // ANALYSIS
      GoRoute(
        path: '/analysis',
        builder: (context, state) {

          final extra =
              state.extra as Map<String, dynamic>?;

          return AnalysisScreen(
            conversationId:
                extra?['conversation_id'] ?? '',
          );
        },
      ),

      // HISTORY
      GoRoute(
        path: '/history',
        builder: (context, state) =>
            const HistoryScreen(),
      ),

      // PROFILE
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const ProfileScreen(),
      ),
    ],
  );
});