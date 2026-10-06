import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<void, NoParams> {
  final AuthRepository _repo;

  SignInWithGoogle(this._repo);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      _repo.signInWithGoogle();
}
