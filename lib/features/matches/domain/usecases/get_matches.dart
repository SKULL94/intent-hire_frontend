import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/match.dart';
import '../repositories/matches_repository.dart';

class GetMatches implements UseCase<List<Match>, MatchFilter> {
  final MatchesRepository _repo;

  GetMatches(this._repo);

  @override
  Future<Either<Failure, List<Match>>> call(MatchFilter params) =>
      _repo.getMatches(params);
}
