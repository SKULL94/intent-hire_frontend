import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
import '../../features/company_detail/data/datasources/company_remote_datasource.dart';
import '../../features/company_detail/data/repositories/company_repository_impl.dart';
import '../../features/company_detail/domain/repositories/company_repository.dart';
import '../../features/company_detail/domain/usecases/get_company_detail.dart';
import '../../features/company_detail/presentation/bloc/company_detail_bloc.dart';
import '../../features/jobs/data/datasources/job_filter_store.dart';
import '../../features/jobs/data/datasources/jobs_remote_datasource.dart';
import '../../features/jobs/data/repositories/jobs_repository_impl.dart';
import '../../features/jobs/domain/repositories/jobs_repository.dart';
import '../../features/jobs/domain/usecases/get_jobs.dart';
import '../../features/jobs/presentation/bloc/jobs_bloc.dart';
import '../../features/matches/data/datasources/match_filter_store.dart';
import '../../features/matches/data/datasources/matches_remote_datasource.dart';
import '../../features/matches/data/repositories/matches_repository_impl.dart';
import '../../features/matches/domain/repositories/matches_repository.dart';
import '../../features/matches/domain/usecases/get_matches.dart';
import '../../features/matches/domain/usecases/refresh_matches.dart';
import '../../features/matches/domain/usecases/update_match_status.dart';
import '../../features/matches/presentation/bloc/matches_bloc.dart';
import '../../features/onboarding/data/datasources/profile_remote_datasource.dart';
import '../../features/onboarding/data/repositories/profile_repository_impl.dart';
import '../../features/onboarding/domain/repositories/profile_repository.dart';
import '../../features/onboarding/domain/usecases/get_profile.dart';
import '../../features/onboarding/domain/usecases/save_profile.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await _registerExternal();
  _registerCore();
  _registerAuth();
  _registerOnboarding();
  _registerMatches();
  _registerJobs();
  _registerCompanyDetail();
  _registerProfile();
}

Future<void> _registerExternal() async {
  getIt
    ..registerLazySingleton<http.Client>(http.Client.new)
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client)
    ..registerLazySingleton<Connectivity>(Connectivity.new);

  // Resolved eagerly so everything downstream can read preferences
  // synchronously — a bloc constructor cannot await.
  getIt.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
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
    ..registerLazySingleton<GetProfile>(() => GetProfile(getIt()))
    ..registerFactory<OnboardingBloc>(
      () => OnboardingBloc(saveProfile: getIt()),
    );
}

void _registerMatches() {
  getIt
    ..registerLazySingleton<MatchesRemoteDataSource>(
      () => MatchesRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<MatchFilterStore>(() => MatchFilterStore(getIt()))
    ..registerLazySingleton<MatchesRepository>(
      () => MatchesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetMatches>(() => GetMatches(getIt()))
    ..registerLazySingleton<RefreshMatches>(() => RefreshMatches(getIt()))
    ..registerLazySingleton<UpdateMatchStatus>(() => UpdateMatchStatus(getIt()))
    ..registerFactory<MatchesBloc>(
      () => MatchesBloc(
        getMatches: getIt(),
        refreshMatches: getIt(),
        updateStatus: getIt(),
        filterStore: getIt(),
      ),
    );
}

void _registerJobs() {
  getIt
    ..registerLazySingleton<JobsRemoteDataSource>(
      () => JobsRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<JobFilterStore>(() => JobFilterStore(getIt()))
    ..registerLazySingleton<JobsRepository>(() => JobsRepositoryImpl(getIt()))
    ..registerLazySingleton<GetJobs>(() => GetJobs(getIt()))
    ..registerFactory<JobsBloc>(
      () => JobsBloc(getJobs: getIt(), filterStore: getIt()),
    );
}

void _registerCompanyDetail() {
  getIt
    ..registerLazySingleton<CompanyRemoteDataSource>(
      () => CompanyRemoteDataSource(getIt()),
    )
    ..registerLazySingleton<CompanyRepository>(
      () => CompanyRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetCompanyDetail>(() => GetCompanyDetail(getIt()))
    ..registerFactory<CompanyDetailBloc>(
      () => CompanyDetailBloc(getCompanyDetail: getIt()),
    );
}

void _registerProfile() {
  // Registered as a factory; AppRouter holds the single instance that the
  // authenticated routes share.
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(getProfile: getIt(), saveProfile: getIt()),
  );
}
