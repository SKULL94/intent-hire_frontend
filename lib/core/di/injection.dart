import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../router/app_router.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_phone_otp.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up_with_email.dart';
import '../../features/auth/domain/usecases/verify_phone_otp.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/onboarding/data/datasources/profile_remote_datasource.dart';
import '../../features/onboarding/data/repositories/profile_repository_impl.dart';
import '../../features/onboarding/domain/repositories/profile_repository.dart';
import '../../features/onboarding/domain/usecases/save_profile.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  _registerExternal();
  _registerCore();
  _registerAuth();
  _registerOnboarding();
}

void _registerExternal() {
  getIt
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client)
    ..registerLazySingleton<Connectivity>(Connectivity.new);
}

void _registerCore() {
  getIt
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt(), getIt()))
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfo(getIt()))
    ..registerLazySingleton<AppRouter>(() => AppRouter(getIt()));
}

void _registerAuth() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<SignInWithEmail>(() => SignInWithEmail(getIt()))
    ..registerLazySingleton<SignUpWithEmail>(() => SignUpWithEmail(getIt()))
    ..registerLazySingleton<SignInWithGoogle>(() => SignInWithGoogle(getIt()))
    ..registerLazySingleton<SendPhoneOtp>(() => SendPhoneOtp(getIt()))
    ..registerLazySingleton<VerifyPhoneOtp>(() => VerifyPhoneOtp(getIt()))
    ..registerLazySingleton<SignOut>(() => SignOut(getIt()))
    ..registerLazySingleton<WatchAuthState>(() => WatchAuthState(getIt()))
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        signInWithEmail: getIt(),
        signUpWithEmail: getIt(),
        signInWithGoogle: getIt(),
        sendPhoneOtp: getIt(),
        verifyPhoneOtp: getIt(),
        signOut: getIt(),
        watchAuthState: getIt(),
      ),
    );
}

void _registerOnboarding() {
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(getIt(), getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<SaveProfile>(() => SaveProfile(getIt()))
    ..registerFactory<OnboardingBloc>(
      () => OnboardingBloc(saveProfile: getIt()),
    );
}
