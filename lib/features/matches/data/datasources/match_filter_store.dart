import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/matches_repository.dart';

/// Local persistence for the matches filter.
///
/// The filter is a display preference, not server state: the backend accepts
/// `min_score` / `min_tech_fit` as query parameters but stores nothing, so
/// without this the sliders reset to 0 on every app start.
///
/// `limit` is deliberately not persisted — it is not user-editable in
/// `FilterSheet`, so a stored value could only ever drift from the default.
class MatchFilterStore {
  static const String _kMinScore = 'matches.min_score';
  static const String _kMinTechFit = 'matches.min_tech_fit';

  final SharedPreferences _prefs;

  const MatchFilterStore(this._prefs);

  MatchFilter read() {
    final minScore = _prefs.getDouble(_kMinScore);
    final minTechFit = _prefs.getDouble(_kMinTechFit);
    if (minScore == null && minTechFit == null) return const MatchFilter();
    return MatchFilter(
      minScore: minScore ?? 0,
      minTechFit: minTechFit ?? 0,
    );
  }

  Future<void> write(MatchFilter filter) async {
    await _prefs.setDouble(_kMinScore, filter.minScore);
    await _prefs.setDouble(_kMinTechFit, filter.minTechFit);
  }
}
