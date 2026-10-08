import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  final ProfileRepository _repo;

  GetProfile(this._repo);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) =>
      _repo.getProfile();
}
