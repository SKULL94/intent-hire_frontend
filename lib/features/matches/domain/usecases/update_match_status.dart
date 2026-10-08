import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/match.dart';
import '../repositories/matches_repository.dart';

class UpdateMatchStatusParams extends Equatable {
  final String matchId;
  final MatchStatus status;

  const UpdateMatchStatusParams({required this.matchId, required this.status});

  @override
  List<Object?> get props => [matchId, status];
}

class UpdateMatchStatus implements UseCase<void, UpdateMatchStatusParams> {
  final MatchesRepository _repo;

  UpdateMatchStatus(this._repo);

  @override
  Future<Either<Failure, void>> call(UpdateMatchStatusParams params) =>
      _repo.updateStatus(params.matchId, params.status);
}
