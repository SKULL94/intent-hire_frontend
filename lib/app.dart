import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

class HireSignalApp extends StatelessWidget {
  const HireSignalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<OnboardingBloc>(create: (_) => getIt<OnboardingBloc>()),
      ],
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
