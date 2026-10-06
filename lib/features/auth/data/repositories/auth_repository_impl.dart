import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.signInWithEmail(
        email: email,
        password: password,
      );
      return Right(model.toEntity());
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final model = await _remote.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      return Right(model.toEntity());
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    try {
      await _remote.signInWithGoogle();
      return const Right(null);
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPhoneOtp({required String phone}) async {
    try {
      await _remote.sendPhoneOtp(phone: phone);
      return const Right(null);
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final model = await _remote.verifyPhoneOtp(phone: phone, token: token);
      return Right(model.toEntity());
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      return const Right(null);
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<AuthUser?> watchAuthState() =>
      _remote.watchAuthState().map((m) => m?.toEntity());

  @override
  AuthUser? get currentUser => _remote.currentUser()?.toEntity();
}
