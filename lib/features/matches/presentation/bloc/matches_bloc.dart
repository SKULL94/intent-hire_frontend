import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../data/datasources/match_filter_store.dart';
import '../../domain/entities/match.dart';
import '../../domain/repositories/matches_repository.dart';
import '../../domain/usecases/get_matches.dart';
import '../../domain/usecases/refresh_matches.dart';
import '../../domain/usecases/update_match_status.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesStateData> {
  final GetMatches _getMatches;
  final RefreshMatches _refreshMatches;
  final UpdateMatchStatus _updateStatus;
  final MatchFilterStore _filterStore;

  MatchesBloc({
    required GetMatches getMatches,
    required RefreshMatches refreshMatches,
    required UpdateMatchStatus updateStatus,
    required MatchFilterStore filterStore,
  })  : _getMatches = getMatches,
        _refreshMatches = refreshMatches,
        _updateStatus = updateStatus,
        _filterStore = filterStore,
        super(const MatchesStateData.initial()) {
    on<MatchesRequested>(_onRequested);
    on<MatchesRefreshRequested>(_onRefresh);
    on<MatchFilterChanged>(_onFilterChanged);
    on<MatchStatusChanged>(_onStatusChanged);
  }

  Future<void> _load(Emitter<MatchesStateData> emit, MatchFilter filter) async {
    final result = await _getMatches(filter);
    result.fold(
      (f) => emit(state.copyWith(
        status: MatchesStatus.failure,
        errorMessage: f.message,
      )),
      (matches) => emit(state.copyWith(
        status: MatchesStatus.loaded,
        matches: matches,
        filter: filter,
        clearError: true,
      )),
    );
  }

  /// Initial load. The filter comes from local storage rather than
  /// `state.filter`, so the sliders the user last applied survive a restart
  /// instead of silently reverting to "show everything".
  Future<void> _onRequested(
    MatchesRequested event,
    Emitter<MatchesStateData> emit,
  ) async {
    final filter = _filterStore.read();
    emit(state.copyWith(
      status: MatchesStatus.loading,
      filter: filter,
      clearError: true,
    ));
    await _load(emit, filter);
  }

  /// Pull-to-refresh. `POST /matches/refresh` returns 202 and recomputes in the
  /// background, so we ask for the recompute and then re-read the list. A fresh
  /// recompute may not have landed yet; the next pull will pick it up.
  Future<void> _onRefresh(
    MatchesRefreshRequested event,
    Emitter<MatchesStateData> emit,
  ) async {
    emit(state.copyWith(status: MatchesStatus.refreshing, clearError: true));
    final queued = await _refreshMatches(const NoParams());
    final failure = queued.fold<String?>((f) => f.message, (_) => null);
    if (failure != null) {
      emit(state.copyWith(status: MatchesStatus.failure, errorMessage: failure));
      return;
    }
    await _load(emit, state.filter);
  }

  Future<void> _onFilterChanged(
    MatchFilterChanged event,
    Emitter<MatchesStateData> emit,
  ) async {
    emit(state.copyWith(status: MatchesStatus.loading, filter: event.filter));
    // Persist before fetching: the user's choice should stick even if the
    // request that follows it fails.
    await _filterStore.write(event.filter);
    await _load(emit, event.filter);
  }

  /// Applied optimistically: the card disappears (or re-labels) immediately and
  /// is restored if the backend rejects the change.
  Future<void> _onStatusChanged(
    MatchStatusChanged event,
    Emitter<MatchesStateData> emit,
  ) async {
    final previous = state.matches;
    emit(state.copyWith(
      matches: previous
          .map((m) => m.id == event.matchId ? m.copyWith(status: event.status) : m)
          .toList(),
    ));

    final result = await _updateStatus(
      UpdateMatchStatusParams(matchId: event.matchId, status: event.status),
    );
    result.fold(
      (f) => emit(state.copyWith(
        matches: previous,
        status: MatchesStatus.failure,
        errorMessage: f.message,
      )),
      (_) {},
    );
  }
}
