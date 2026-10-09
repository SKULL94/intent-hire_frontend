import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../models/job_model.dart';

class JobsRemoteDataSource {
  final ApiClient _api;

  JobsRemoteDataSource(this._api);

  Future<List<Job>> getJobs(JobFilter filter) async {
    final data = await _api.get(
      ApiEndpoints.jobs,
      query: {
        // Sets become repeated query parameters; omitted entirely when empty
        // so the backend does not apply the filter at all.
        if (filter.technologies.isNotEmpty) 'tech': filter.technologies.toList(),
        if (filter.locations.isNotEmpty) 'location': filter.locations.toList(),
        if (filter.includeRemote) 'remote': true,
        if (filter.maxYearsExperience != null)
          'max_years': filter.maxYearsExperience,
        'sort': filter.sort.wire,
        'limit': filter.limit,
      },
    );
    if (data is! List<dynamic>) return const <Job>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(JobModel.fromJson)
        .toList();
  }
}
