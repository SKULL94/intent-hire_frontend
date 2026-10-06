import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  Future<Either<Failure, void>> signInWithGoogle();

  /// Sends an SMS OTP. Supabase creates the account on first use.
  Future<Either<Failure, void>> sendPhoneOtp({required String phone});

  Future<Either<Failure, AuthUser>> verifyPhoneOtp({
    required String phone,
    required String token,
  });

  Future<Either<Failure, void>> signOut();

  Stream<AuthUser?> watchAuthState();

  AuthUser? get currentUser;
}
