import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/error/failures.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_datasource.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource _remote;

  JobsRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Job>>> getJobs(JobFilter filter) async {
    try {
      return Right(await _remote.getJobs(filter));
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
