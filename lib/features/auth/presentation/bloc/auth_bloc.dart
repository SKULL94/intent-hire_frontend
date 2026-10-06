import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/send_phone_otp.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/verify_phone_otp.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStateData> {
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SendPhoneOtp _sendPhoneOtp;
  final VerifyPhoneOtp _verifyPhoneOtp;
  final SignOut _signOut;
  final WatchAuthState _watchAuthState;

  StreamSubscription<AuthUser?>? _sub;

  AuthBloc({
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SendPhoneOtp sendPhoneOtp,
    required VerifyPhoneOtp verifyPhoneOtp,
    required SignOut signOut,
    required WatchAuthState watchAuthState,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signInWithGoogle = signInWithGoogle,
        _sendPhoneOtp = sendPhoneOtp,
        _verifyPhoneOtp = verifyPhoneOtp,
        _signOut = signOut,
        _watchAuthState = watchAuthState,
        super(const AuthStateData.initial()) {
    on<AuthStarted>(_onStarted);
    on<SignInWithEmailRequested>(_onSignIn);
    on<SignUpWithEmailRequested>(_onSignUp);
    on<SignInWithGoogleRequested>(_onGoogle);
    on<SendPhoneOtpRequested>(_onSendPhoneOtp);
    on<VerifyPhoneOtpRequested>(_onVerifyPhoneOtp);
    on<PhoneOtpReset>(_onPhoneOtpReset);
    on<SignOutRequested>(_onSignOut);
    on<_AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthStateData> emit) async {
    final current = _watchAuthState.currentUser;
    emit(state.copyWith(
      status: current == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated,
      user: current,
      clearUser: current == null,
    ));
    await _sub?.cancel();
    _sub = _watchAuthState().listen((user) => add(_AuthUserChanged(user)));
  }

  Future<void> _onSignIn(
    SignInWithEmailRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _signInWithEmail(SignInWithEmailParams(
      email: event.email,
      password: event.password,
    ));
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  Future<void> _onSignUp(
    SignUpWithEmailRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _signUpWithEmail(SignUpWithEmailParams(
      email: event.email,
      password: event.password,
      name: event.name,
    ));
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  Future<void> _onGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _signInWithGoogle(const NoParams());
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtpRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _sendPhoneOtp(SendPhoneOtpParams(phone: event.phone));
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(
        submitting: false,
        otpSent: true,
        otpPhone: event.phone,
      )),
    );
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _verifyPhoneOtp(VerifyPhoneOtpParams(
      phone: event.phone,
      token: event.token,
    ));
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(submitting: false, clearOtp: true)),
    );
  }

  void _onPhoneOtpReset(PhoneOtpReset event, Emitter<AuthStateData> emit) {
    emit(state.copyWith(clearOtp: true, clearError: true));
  }

  Future<void> _onSignOut(
    SignOutRequested event,
    Emitter<AuthStateData> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    final res = await _signOut(const NoParams());
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errorMessage: f.message)),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthStateData> emit) {
    emit(state.copyWith(
      status: event.user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated,
      user: event.user,
      clearUser: event.user == null,
    ));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
