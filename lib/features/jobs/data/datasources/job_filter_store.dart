import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/jobs_repository.dart';

/// Local persistence for the job search filter.
///
/// Same reasoning as [MatchFilterStore]: the backend treats these as query
/// parameters and stores nothing, so without this the user re-picks Flutter +
/// Delhi NCR on every launch.
///
/// A first run has nothing stored and falls back to [JobFilter.flutterDefault]
/// rather than an empty filter, so the first screen shows something useful.
class JobFilterStore {
  static const String _kTech = 'jobs.technologies';
  static const String _kLocations = 'jobs.locations';
  static const String _kRemote = 'jobs.include_remote';
  static const String _kMaxYears = 'jobs.max_years';
  static const String _kSort = 'jobs.sort';
  // Distinguishes "never saved" from "saved an empty filter", which otherwise
  // look identical and would keep resetting the user to the default.
  static const String _kSaved = 'jobs.saved';

  final SharedPreferences _prefs;

  const JobFilterStore(this._prefs);

  JobFilter read() {
    if (!(_prefs.getBool(_kSaved) ?? false)) return JobFilter.flutterDefault;
    return JobFilter(
      technologies: (_prefs.getStringList(_kTech) ?? const []).toSet(),
      locations: (_prefs.getStringList(_kLocations) ?? const []).toSet(),
      includeRemote: _prefs.getBool(_kRemote) ?? false,
      maxYearsExperience: _prefs.getInt(_kMaxYears),
      sort: JobSortWire.parse(_prefs.getString(_kSort)),
    );
  }

  Future<void> write(JobFilter filter) async {
    await _prefs.setStringList(_kTech, filter.technologies.toList());
    await _prefs.setStringList(_kLocations, filter.locations.toList());
    await _prefs.setBool(_kRemote, filter.includeRemote);
    await _prefs.setString(_kSort, filter.sort.wire);
    final years = filter.maxYearsExperience;
    if (years == null) {
      await _prefs.remove(_kMaxYears);
    } else {
      await _prefs.setInt(_kMaxYears, years);
    }
    await _prefs.setBool(_kSaved, true);
  }
}
