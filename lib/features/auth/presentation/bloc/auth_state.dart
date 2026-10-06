part of 'auth_bloc.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthStateData extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final bool submitting;
  final String? errorMessage;
  final bool otpSent;
  final String? otpPhone;

  const AuthStateData({
    this.status = AuthStatus.unknown,
    this.user,
    this.submitting = false,
    this.errorMessage,
    this.otpSent = false,
    this.otpPhone,
  });

  const AuthStateData.initial() : this();

  AuthStateData copyWith({
    AuthStatus? status,
    AuthUser? user,
    bool? submitting,
    String? errorMessage,
    bool? otpSent,
    String? otpPhone,
    bool clearError = false,
    bool clearUser = false,
    bool clearOtp = false,
  }) {
    return AuthStateData(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSent: clearOtp ? false : (otpSent ?? this.otpSent),
      otpPhone: clearOtp ? null : (otpPhone ?? this.otpPhone),
    );
  }

  @override
  List<Object?> get props =>
      [status, user, submitting, errorMessage, otpSent, otpPhone];
}
