import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/match.dart';

class MatchFilter {
  final double minScore;
  final double minTechFit;
  final int limit;

  const MatchFilter({
    this.minScore = 0,
    this.minTechFit = 0,
    this.limit = 20,
  });

  MatchFilter copyWith({double? minScore, double? minTechFit, int? limit}) =>
      MatchFilter(
        minScore: minScore ?? this.minScore,
        minTechFit: minTechFit ?? this.minTechFit,
        limit: limit ?? this.limit,
      );

  bool get isDefault => minScore == 0 && minTechFit == 0;
}

abstract class MatchesRepository {
  Future<Either<Failure, List<Match>>> getMatches(MatchFilter filter);

  /// Asks the backend to recompute this user's matches. The API returns 202 and
  /// does the work in the background, so the caller must re-fetch afterwards.
  Future<Either<Failure, void>> refreshMatches();

  Future<Either<Failure, void>> updateStatus(String matchId, MatchStatus status);
}
