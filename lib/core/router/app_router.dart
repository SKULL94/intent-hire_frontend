import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/home_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/skill_setup_page.dart';
import 'route_paths.dart';

class AppRouter {
  final SupabaseClient _supabase;

  AppRouter(this._supabase);

  late final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: _AuthRefresh(_supabase),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: RoutePaths.skillSetup,
        builder: (_, __) => const SkillSetupPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.matches,
            builder: (_, __) => const _PlaceholderPage(title: 'Matches'),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (_, __) => const _PlaceholderPage(title: 'Profile'),
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final loggedIn = _supabase.auth.currentUser != null;
    final location = state.matchedLocation;

    final isAuthRoute = location == RoutePaths.login ||
        location == RoutePaths.signup;
    final isSplash = location == RoutePaths.splash;

    if (!loggedIn && !isAuthRoute && !isSplash) {
      return RoutePaths.login;
    }
    if (loggedIn && (isAuthRoute || isSplash)) {
      return RoutePaths.matches;
    }
    return null;
  }
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(SupabaseClient supabase) {
    _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// Temporary placeholder until Week 6/7 matches and profile features land.
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — coming in Week 6/7')),
      );
}
