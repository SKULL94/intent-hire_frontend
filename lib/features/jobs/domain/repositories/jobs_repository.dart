import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/job.dart';

enum JobSort { recent, intent, salary }

extension JobSortWire on JobSort {
  String get wire => switch (this) {
        JobSort.recent => 'recent',
        JobSort.intent => 'intent',
        JobSort.salary => 'salary',
      };

  String get label => switch (this) {
        JobSort.recent => 'Most recent',
        JobSort.intent => 'Hiring intent',
        JobSort.salary => 'Salary',
      };

  static JobSort parse(String? value) => switch (value) {
        'intent' => JobSort.intent,
        'salary' => JobSort.salary,
        _ => JobSort.recent,
      };
}

/// Query for `GET /api/v1/jobs`.
///
/// Technologies and locations are sets because the endpoint matches ANY of
/// them: a Flutter role that never spells out "Dart" is still a Flutter role,
/// and someone open to NCR *or* remote wants both in one list.
class JobFilter extends Equatable {
  final Set<String> technologies;
  final Set<String> locations;
  final bool includeRemote;
  final int? maxYearsExperience;
  final JobSort sort;
  final int limit;

  const JobFilter({
    this.technologies = const {},
    this.locations = const {},
    this.includeRemote = false,
    this.maxYearsExperience,
    this.sort = JobSort.recent,
    this.limit = 50,
  });

  /// What a Flutter developer in NCR would pick, used for a first run so the
  /// list is useful before the user touches the filter sheet.
  static const JobFilter flutterDefault = JobFilter(
    technologies: {'flutter', 'dart'},
    locations: {JobLocations.delhiNcr},
    includeRemote: true,
  );

  JobFilter copyWith({
    Set<String>? technologies,
    Set<String>? locations,
    bool? includeRemote,
    int? maxYearsExperience,
    bool clearMaxYears = false,
    JobSort? sort,
    int? limit,
  }) =>
      JobFilter(
        technologies: technologies ?? this.technologies,
        locations: locations ?? this.locations,
        includeRemote: includeRemote ?? this.includeRemote,
        maxYearsExperience:
            clearMaxYears ? null : (maxYearsExperience ?? this.maxYearsExperience),
        sort: sort ?? this.sort,
        limit: limit ?? this.limit,
      );

  bool get isDefault =>
      technologies.isEmpty &&
      locations.isEmpty &&
      !includeRemote &&
      maxYearsExperience == null;

  int get activeCount =>
      (technologies.isNotEmpty ? 1 : 0) +
      (locations.isNotEmpty || includeRemote ? 1 : 0) +
      (maxYearsExperience != null ? 1 : 0);

  @override
  List<Object?> get props => [
        technologies,
        locations,
        includeRemote,
        maxYearsExperience,
        sort,
        limit,
      ];
}

abstract class JobsRepository {
  Future<Either<Failure, List<Job>>> getJobs(JobFilter filter);
}
