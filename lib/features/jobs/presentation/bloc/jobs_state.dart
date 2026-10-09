part of 'jobs_bloc.dart';

enum JobsStatus { initial, loading, refreshing, loaded, failure }

class JobsStateData extends Equatable {
  final List<Job> jobs;
  final JobFilter filter;
  final JobsStatus status;
  final String? errorMessage;

  const JobsStateData({
    this.jobs = const [],
    this.filter = JobFilter.flutterDefault,
    this.status = JobsStatus.initial,
    this.errorMessage,
  });

  const JobsStateData.initial()
      : jobs = const [],
        filter = JobFilter.flutterDefault,
        status = JobsStatus.initial,
        errorMessage = null;

  JobsStateData copyWith({
    List<Job>? jobs,
    JobFilter? filter,
    JobsStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      JobsStateData(
        jobs: jobs ?? this.jobs,
        filter: filter ?? this.filter,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get isBusy =>
      status == JobsStatus.loading || status == JobsStatus.refreshing;

  bool get showEmptyState => status == JobsStatus.loaded && jobs.isEmpty;

  /// Technologies present in the current results, most common first. Drives
  /// the quick-toggle chips, so the UI only ever offers a filter that the
  /// loaded data can actually satisfy.
  List<String> get availableTechnologies {
    final counts = <String, int>{};
    for (final job in jobs) {
      for (final tech in job.technologies.keys) {
        counts[tech] = (counts[tech] ?? 0) + 1;
      }
    }
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sorted.take(12).toList();
  }

  @override
  List<Object?> get props => [jobs, filter, status, errorMessage];
}
