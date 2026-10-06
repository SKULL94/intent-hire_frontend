import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmailParams extends Equatable {
  final String email;
  final String password;
  final String? name;
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class SignUpWithEmail implements UseCase<AuthUser, SignUpWithEmailParams> {
  final AuthRepository _repo;

  SignUpWithEmail(this._repo);

  @override
  Future<Either<Failure, AuthUser>> call(SignUpWithEmailParams params) =>
      _repo.signUpWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
      );
}
