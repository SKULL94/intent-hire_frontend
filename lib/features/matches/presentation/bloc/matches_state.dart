part of 'matches_bloc.dart';

enum MatchesStatus { initial, loading, refreshing, loaded, failure }

class MatchesStateData extends Equatable {
  final List<Match> matches;
  final MatchFilter filter;
  final MatchesStatus status;
  final String? errorMessage;

  const MatchesStateData({
    this.matches = const [],
    this.filter = const MatchFilter(),
    this.status = MatchesStatus.initial,
    this.errorMessage,
  });

  const MatchesStateData.initial()
      : matches = const [],
        filter = const MatchFilter(),
        status = MatchesStatus.initial,
        errorMessage = null;

  MatchesStateData copyWith({
    List<Match>? matches,
    MatchFilter? filter,
    MatchesStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      MatchesStateData(
        matches: matches ?? this.matches,
        filter: filter ?? this.filter,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  /// Dismissed matches stay in the payload but should not occupy the list.
  List<Match> get visible =>
      matches.where((m) => m.status != MatchStatus.dismissed).toList();

  bool get isBusy =>
      status == MatchesStatus.loading || status == MatchesStatus.refreshing;

  bool get showEmptyState =>
      status == MatchesStatus.loaded && visible.isEmpty;

  @override
  List<Object?> get props => [
        matches,
        filter.minScore,
        filter.minTechFit,
        filter.limit,
        status,
        errorMessage,
      ];
}
