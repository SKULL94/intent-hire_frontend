import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/injection.dart';
import '../widgets/home_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/company_detail/presentation/bloc/company_detail_bloc.dart';
import '../../features/company_detail/presentation/pages/company_detail_page.dart';
import '../../features/matches/presentation/bloc/matches_bloc.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../../features/onboarding/presentation/pages/skill_setup_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_skills_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'route_paths.dart';

class AppRouter {
  final SupabaseClient _supabase;

  AppRouter(this._supabase);

  /// `ProfileBloc` is created once and shared across the authenticated routes:
  /// the profile tab edits it, and the matches list reads the user's skills
  /// from it to highlight overlapping technologies.
  late final ProfileBloc _profileBloc = getIt<ProfileBloc>()
    ..add(const ProfileRequested());

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
        builder: (_, __, child) => BlocProvider<ProfileBloc>.value(
          value: _profileBloc,
          child: HomeShell(child: child),
        ),
        routes: [
          GoRoute(
            path: RoutePaths.matches,
            builder: (_, __) => BlocProvider<MatchesBloc>(
              create: (_) =>
                  getIt<MatchesBloc>()..add(const MatchesRequested()),
              child: const MatchesPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
      // Pushed over the shell, so these keep their own Scaffold and back button
      // but still need ProfileBloc for the user's skills.
      GoRoute(
        path: RoutePaths.editSkills,
        builder: (_, __) => BlocProvider<ProfileBloc>.value(
          value: _profileBloc,
          child: const EditSkillsPage(),
        ),
      ),
      GoRoute(
        path: '${RoutePaths.company}/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>.value(value: _profileBloc),
              BlocProvider<CompanyDetailBloc>(
                create: (_) => getIt<CompanyDetailBloc>()
                  ..add(CompanyDetailRequested(id)),
              ),
            ],
            child: CompanyDetailPage(companyId: id),
          );
        },
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
