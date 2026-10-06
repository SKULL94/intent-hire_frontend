import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class SaveProfile implements UseCase<void, UserProfile> {
  final ProfileRepository _repo;

  SaveProfile(this._repo);

  @override
  Future<Either<Failure, void>> call(UserProfile params) =>
      _repo.saveProfile(params);
}
