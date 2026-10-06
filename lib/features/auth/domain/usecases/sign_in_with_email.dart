import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;
  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignInWithEmail implements UseCase<AuthUser, SignInWithEmailParams> {
  final AuthRepository _repo;

  SignInWithEmail(this._repo);

  @override
  Future<Either<Failure, AuthUser>> call(SignInWithEmailParams params) =>
      _repo.signInWithEmail(email: params.email, password: params.password);
}
