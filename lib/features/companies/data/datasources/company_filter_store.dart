import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/company_filter.dart';

/// Persists the filter so reopening the app does not reset the question.
class CompanyFilterStore {
  static const String _key = 'company_filter_v1';

  final SharedPreferences _prefs;

  CompanyFilterStore(this._prefs);

  CompanyFilter read() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return CompanyFilter.initial;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return CompanyFilter.fromJson(decoded);
      }
    } on FormatException {
      // Stored value from an older build; fall through to the default rather
      // than failing the first frame.
    }
    return CompanyFilter.initial;
  }

  Future<void> write(CompanyFilter filter) =>
      _prefs.setString(_key, jsonEncode(filter.toJson()));
}
