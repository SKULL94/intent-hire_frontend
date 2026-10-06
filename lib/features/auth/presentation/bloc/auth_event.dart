part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SendPhoneOtpRequested extends AuthEvent {
  final String phone;
  const SendPhoneOtpRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class VerifyPhoneOtpRequested extends AuthEvent {
  final String phone;
  final String token;
  const VerifyPhoneOtpRequested({required this.phone, required this.token});

  @override
  List<Object?> get props => [phone, token];
}

class PhoneOtpReset extends AuthEvent {
  const PhoneOtpReset();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class _AuthUserChanged extends AuthEvent {
  final AuthUser? user;
  const _AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
