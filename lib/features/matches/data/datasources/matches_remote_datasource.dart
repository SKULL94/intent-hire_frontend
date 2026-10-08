import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';
import '../models/match_model.dart';

class MatchesRemoteDataSource {
  final ApiClient _api;

  MatchesRemoteDataSource(this._api);

  Future<List<Match>> getMatches(MatchFilter filter) async {
    final data = await _api.get(
      ApiEndpoints.matches,
      query: {
        'min_score': filter.minScore,
        'min_tech_fit': filter.minTechFit,
        'limit': filter.limit,
      },
    );
    if (data is! List<dynamic>) return const <Match>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(MatchModel.fromJson)
        .toList();
  }

  Future<void> refreshMatches() => _api.post(ApiEndpoints.matchesRefresh);

  Future<void> updateStatus(String matchId, MatchStatus status) => _api.patch(
        ApiEndpoints.patchMatchById(matchId),
        body: {'status': status.wire},
      );
}
