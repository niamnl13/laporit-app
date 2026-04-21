import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:laporit_app/features/auth/login.dart';
import 'package:laporit_app/features/user/dashboard_user.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardUser(),
      ),
    ],
  );
}