import '../../domain/entities/company_summary.dart';
import '../../domain/entities/match.dart';
import '../../domain/entities/signal_summary.dart';

/// Parsers for `GET /api/v1/matches` (schema: `MatchWithCompany`).
///
/// Written by hand rather than generated: the payload nests `company` and
/// `company_score` and flattens them into one entity, which is clearer as
/// explicit code than as codegen plus a mapper.
class MatchModel {
  const MatchModel._();

  static Match fromJson(Map<String, dynamic> json) {
    final company = _asMap(json['company']);
    final score = _asMap(json['company_score']);

    return Match(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      score: _toDouble(json['score']),
      techFit: _toDouble(json['tech_fit']),
      intentScore: _toDouble(json['intent_score']),
      status: MatchStatusWire.parse(json['status'] as String?),
      matchedAt: _toDate(json['matched_at']),
      topSignals: _signals(json['top_signals']),
      company: CompanySummary(
        id: company['id'] as String? ?? json['company_id'] as String,
        name: company['name'] as String? ?? 'Unknown',
        domain: company['domain'] as String?,
        careersUrl: company['careers_url'] as String?,
        atsType: company['ats_type'] as String?,
        industry: company['industry'] as String?,
        location: company['location'] as String?,
        logoUrl: company['logo_url'] as String?,
        employeeCount: company['employee_count'] as int?,
        stackFingerprint: stackFrom(score['stack_fingerprint']),
        signalCount: score['signal_count'] as int? ?? 0,
        strongestSignal: score['strongest_signal'] as String?,
      ),
    );
  }

  /// `stack_fingerprint` is `{tech: confidence}`; the numbers arrive as int or
  /// double depending on the value, so normalize to double.
  static Map<String, double> stackFrom(Object? raw) {
    final map = _asMap(raw);
    final out = <String, double>{};
    for (final entry in map.entries) {
      final value = entry.value;
      if (value is num) out[entry.key] = value.toDouble();
    }
    return out;
  }

  static List<SignalSummary> _signals(Object? raw) {
    if (raw is! List<dynamic>) return const <SignalSummary>[];
    return raw.map(_asMap).where((m) => m.isNotEmpty).map((m) {
      return SignalSummary(
        signalType: m['signal_type'] as String? ?? 'unknown',
        source: m['source'] as String? ?? '',
        confidence: _toDouble(m['confidence']),
        detectedAt: _toDate(m['detected_at']),
      );
    }).toList();
  }

  static Map<String, dynamic> _asMap(Object? raw) =>
      raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

  static double _toDouble(Object? v) => v is num ? v.toDouble() : 0.0;

  static DateTime _toDate(Object? v) => v is String
      ? (DateTime.tryParse(v)?.toLocal() ?? DateTime.now())
      : DateTime.now();
}
