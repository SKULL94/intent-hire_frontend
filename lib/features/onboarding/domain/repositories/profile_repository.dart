import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, void>> saveProfile(UserProfile profile);

  /// The signed-in user's stored profile. Fails with `ServerFailure(404)` when
  /// onboarding has not been completed.
  Future<Either<Failure, UserProfile>> getProfile();
}
