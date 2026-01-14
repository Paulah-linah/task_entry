import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/task_form_page.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _removeListener = ref.listen<AuthState>(authControllerProvider, (_, __) {
      notifyListeners();
    }).close;
  }

  late final void Function() _removeListener;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);

      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isLogin = location == '/login';
      final isSignup = location == '/signup';

      if (auth.isLoading) {
        return isSplash ? null : '/splash';
      }

      final isAuthed = auth.isAuthenticated;

      if (!isAuthed) {
        if (isLogin || isSignup) return null;
        if (isSplash) return '/login';
        return '/login';
      }

      if (isLogin || isSignup || isSplash) {
        return '/dashboard';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const MaterialPage(child: SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => const MaterialPage(child: SignUpPage()),
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
