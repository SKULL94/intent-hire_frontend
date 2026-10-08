part of 'matches_bloc.dart';

sealed class MatchesEvent extends Equatable {
  const MatchesEvent();

  @override
  List<Object?> get props => const [];
}

class MatchesRequested extends MatchesEvent {
  const MatchesRequested();
}

class MatchesRefreshRequested extends MatchesEvent {
  const MatchesRefreshRequested();
}

class MatchFilterChanged extends MatchesEvent {
  final MatchFilter filter;
  const MatchFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter.minScore, filter.minTechFit, filter.limit];
}

class MatchStatusChanged extends MatchesEvent {
  final String matchId;
  final MatchStatus status;
  const MatchStatusChanged(this.matchId, this.status);

  @override
  List<Object?> get props => [matchId, status];
}
