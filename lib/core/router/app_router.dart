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
import '../../features/companies/presentation/bloc/companies_bloc.dart';
import '../../features/companies/presentation/bloc/company_detail_bloc.dart';
import '../../features/companies/presentation/pages/companies_page.dart';
import '../../features/companies/presentation/pages/company_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'route_paths.dart';

class AppRouter {
  final SupabaseClient _supabase;

  AppRouter(this._supabase);

  /// Held for the app's lifetime so switching to Profile and back does not
  /// refetch the list or lose the user's place in it.
  late final CompaniesBloc _companiesBloc = getIt<CompaniesBloc>()
    ..add(const CompaniesRequested());

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
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.companies,
            builder: (_, __) => BlocProvider<CompaniesBloc>.value(
              value: _companiesBloc,
              child: const CompaniesPage(),
            ),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (_, __) => const ProfilePage(),
          ),
        ],
      ),
      // Pushed over the shell, so it keeps its own Scaffold and back button.
      GoRoute(
        path: '${RoutePaths.company}/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return BlocProvider<CompanyDetailBloc>(
            create: (_) =>
                getIt<CompanyDetailBloc>()..add(CompanyDetailRequested(id)),
            child: CompanyDetailPage(companyId: id),
          );
        },
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final loggedIn = _supabase.auth.currentUser != null;
    final location = state.matchedLocation;

    final isAuthRoute =
        location == RoutePaths.login || location == RoutePaths.signup;
    final isSplash = location == RoutePaths.splash;

    if (!loggedIn && !isAuthRoute && !isSplash) {
      return RoutePaths.login;
    }
    if (loggedIn && (isAuthRoute || isSplash)) {
      return RoutePaths.companies;
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
