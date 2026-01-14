import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/task_form_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (context, state) => const MaterialPage(child: DashboardPage()),
      ),
      GoRoute(
        path: '/task/new',
        pageBuilder: (context, state) => const MaterialPage(child: TaskFormPage()),
      ),
    ],
  );
});
