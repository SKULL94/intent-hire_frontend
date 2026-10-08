import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/matches_repository.dart';

class RefreshMatches implements UseCase<void, NoParams> {
  final MatchesRepository _repo;

  RefreshMatches(this._repo);

  @override
  Future<Either<Failure, void>> call(NoParams params) => _repo.refreshMatches();
}
