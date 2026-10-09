part of 'jobs_bloc.dart';

sealed class JobsEvent extends Equatable {
  const JobsEvent();

  @override
  List<Object?> get props => const [];
}

/// Initial load. Reads the stored filter rather than using the current state,
/// so a restart restores the user's last search.
class JobsRequested extends JobsEvent {
  const JobsRequested();
}

class JobsRefreshRequested extends JobsEvent {
  const JobsRefreshRequested();
}

class JobFilterChanged extends JobsEvent {
  final JobFilter filter;
  const JobFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Toggling one technology chip straight from the results header, without
/// opening the filter sheet.
class JobTechnologyToggled extends JobsEvent {
  final String technology;
  const JobTechnologyToggled(this.technology);

  @override
  List<Object?> get props => [technology];
}

class JobSortChanged extends JobsEvent {
  final JobSort sort;
  const JobSortChanged(this.sort);

  @override
  List<Object?> get props => [sort];
}
