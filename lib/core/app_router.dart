import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../ui/auth/auth_screen.dart';
import '../ui/root_layout.dart';
import '../ui/splash_screen.dart';
import '../ui/notifications/notifications_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App Router: Navigation configuration with authentication guards
class AppRouter {
  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: userProvider,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const RootLayout(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
      redirect: (context, state) {
        final currentPath = state.uri.toString();
        debugPrint('[AppRouter] Redirect check: Path=$currentPath, Init=${userProvider.initComplete}, Auth=${userProvider.currentUser != null}');

        // 1. Still initializing - show splash screen
        if (!userProvider.initComplete) {
          if (currentPath != '/splash') {
            return '/splash';
          }
          return null; // Already at splash
        }

        // 2. After initialization is complete, route based on auth state
        final isAuthenticated = userProvider.currentUser != null;

        // If at splash and init is complete, redirect based on auth
        if (currentPath == '/splash') {
          return isAuthenticated ? '/' : '/login';
        }

        // Define auth screens (unauthenticated-only routes)
        const loginPath = '/login';

        if (isAuthenticated) {
          // If user is logged in but tries to access login/auth screens, redirect to home
          if (currentPath == loginPath) {
            return '/';
          }
        } else {
          // If user is NOT logged in and tries to access protected screens, redirect to login
          if (currentPath != loginPath) {
            return '/login';
          }
        }

        return null;
      },
    );
  }
}
