import '../../../matches/data/models/match_model.dart';
import '../../../matches/domain/entities/signal_summary.dart';
import '../../domain/entities/company_detail.dart';

/// Parser for `GET /api/v1/companies/{id}` (schema: `CompanyDetail`).
class CompanyDetailModel {
  const CompanyDetailModel._();

  static CompanyDetail fromJson(Map<String, dynamic> json) {
    final score = _asMap(json['score']);
    return CompanyDetail(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown',
      domain: json['domain'] as String?,
      careersUrl: json['careers_url'] as String?,
      website: json['website'] as String?,
      atsType: json['ats_type'] as String?,
      githubOrg: json['github_org'] as String?,
      industry: json['industry'] as String?,
      location: json['location'] as String?,
      employeeCount: json['employee_count'] as int?,
      intentScore: _toDouble(score['intent_score']),
      signalCount: score['signal_count'] as int? ?? 0,
      strongestSignal: score['strongest_signal'] as String?,
      stackFingerprint: MatchModel.stackFrom(score['stack_fingerprint']),
      intentSignals: _intentSignals(json['intent_signals']),
      stackSignals: _stackSignals(json['stack_signals']),
    );
  }

  static List<SignalSummary> _intentSignals(Object? raw) {
    if (raw is! List<dynamic>) return const <SignalSummary>[];
    final signals = raw
        .whereType<Map<String, dynamic>>()
        .map((m) => SignalSummary(
              signalType: m['signal_type'] as String? ?? 'unknown',
              source: m['source'] as String? ?? '',
              confidence: _toDouble(m['confidence']),
              detectedAt: _toDate(m['detected_at']),
            ))
        .toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return signals;
  }

  static List<StackObservation> _stackSignals(Object? raw) {
    if (raw is! List<dynamic>) return const <StackObservation>[];
    final observations = raw
        .whereType<Map<String, dynamic>>()
        .map((m) => StackObservation(
              sourceType: m['source_type'] as String? ?? 'unknown',
              sourceUrl: m['source_url'] as String?,
              technologies: MatchModel.stackFrom(m['technologies']),
              detectedAt: _toDate(m['detected_at']),
            ))
        .toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return observations;
  }

  static Map<String, dynamic> _asMap(Object? raw) =>
      raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

  static double _toDouble(Object? v) => v is num ? v.toDouble() : 0.0;

  static DateTime _toDate(Object? v) => v is String
      ? (DateTime.tryParse(v)?.toLocal() ?? DateTime.now())
      : DateTime.now();
}
