import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/job.dart';
import '../repositories/jobs_repository.dart';

class GetJobs implements UseCase<List<Job>, JobFilter> {
  final JobsRepository _repo;

  GetJobs(this._repo);

  @override
  Future<Either<Failure, List<Job>>> call(JobFilter params) =>
      _repo.getJobs(params);
}
