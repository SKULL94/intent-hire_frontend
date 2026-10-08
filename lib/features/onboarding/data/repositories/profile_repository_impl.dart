import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, void>> saveProfile(UserProfile profile) => _guard(
        () async {
          await _remote.saveProfile(UserProfileModel.fromEntity(profile));
        },
      );

  @override
  Future<Either<Failure, UserProfile>> getProfile() =>
      _guard(() async => (await _remote.getProfile()).toEntity());

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on app_errors.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
