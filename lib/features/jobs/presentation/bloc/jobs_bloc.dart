import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/job_filter_store.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../../domain/usecases/get_jobs.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobsBloc extends Bloc<JobsEvent, JobsStateData> {
  final GetJobs _getJobs;
  final JobFilterStore _filterStore;

  JobsBloc({
    required GetJobs getJobs,
    required JobFilterStore filterStore,
  })  : _getJobs = getJobs,
        _filterStore = filterStore,
        super(const JobsStateData.initial()) {
    on<JobsRequested>(_onRequested);
    on<JobsRefreshRequested>(_onRefresh);
    on<JobFilterChanged>(_onFilterChanged);
    on<JobTechnologyToggled>(_onTechnologyToggled);
    on<JobSortChanged>(_onSortChanged);
  }

  Future<void> _load(Emitter<JobsStateData> emit, JobFilter filter) async {
    final result = await _getJobs(filter);
    result.fold(
      (f) => emit(state.copyWith(
        status: JobsStatus.failure,
        errorMessage: f.message,
      )),
      (jobs) => emit(state.copyWith(
        status: JobsStatus.loaded,
        jobs: jobs,
        filter: filter,
        clearError: true,
      )),
    );
  }

  /// Applies a filter and persists it, so the choice survives a restart even
  /// if the fetch that follows fails.
  Future<void> _applyFilter(
    Emitter<JobsStateData> emit,
    JobFilter filter,
  ) async {
    emit(state.copyWith(status: JobsStatus.loading, filter: filter));
    await _filterStore.write(filter);
    await _load(emit, filter);
  }

  Future<void> _onRequested(
    JobsRequested event,
    Emitter<JobsStateData> emit,
  ) async {
    final filter = _filterStore.read();
    emit(state.copyWith(
      status: JobsStatus.loading,
      filter: filter,
      clearError: true,
    ));
    await _load(emit, filter);
  }

  Future<void> _onRefresh(
    JobsRefreshRequested event,
    Emitter<JobsStateData> emit,
  ) async {
    emit(state.copyWith(status: JobsStatus.refreshing, clearError: true));
    await _load(emit, state.filter);
  }

  Future<void> _onFilterChanged(
    JobFilterChanged event,
    Emitter<JobsStateData> emit,
  ) =>
      _applyFilter(emit, event.filter);

  Future<void> _onTechnologyToggled(
    JobTechnologyToggled event,
    Emitter<JobsStateData> emit,
  ) {
    final technologies = Set<String>.from(state.filter.technologies);
    if (!technologies.remove(event.technology)) {
      technologies.add(event.technology);
    }
    return _applyFilter(emit, state.filter.copyWith(technologies: technologies));
  }

  Future<void> _onSortChanged(
    JobSortChanged event,
    Emitter<JobsStateData> emit,
  ) =>
      _applyFilter(emit, state.filter.copyWith(sort: event.sort));
}
