import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

class HireSignalApp extends StatelessWidget {
  const HireSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth is the only app-wide bloc. The companies list is held by AppRouter
    // so it survives tab switches, and the detail bloc is per-route.
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
      child: MaterialApp.router(
        title: 'HireSignal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}
