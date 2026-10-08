import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/error/failures.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';
import '../datasources/matches_remote_datasource.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  final MatchesRemoteDataSource _remote;

  MatchesRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Match>>> getMatches(MatchFilter filter) =>
      _guard(() => _remote.getMatches(filter));

  @override
  Future<Either<Failure, void>> refreshMatches() =>
      _guard(() => _remote.refreshMatches());

  @override
  Future<Either<Failure, void>> updateStatus(String matchId, MatchStatus status) =>
      _guard(() => _remote.updateStatus(matchId, status));

  /// Maps the data layer's exceptions onto domain failures. Every method here
  /// shares the same mapping, so it lives in one place.
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
