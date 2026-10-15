import '../../domain/entities/company.dart';

/// Parser for `/api/v1/companies` (schema `CompanyListItem`) and
/// `/api/v1/companies/{id}` (schema `CompanyDetail`).
///
/// The list response carries no evidence — only the detail response embeds
/// `stack_signals` and `intent_signals` — so both shapes go through here and
/// the evidence lists simply come back empty for list items.
class CompanyModel {
  const CompanyModel._();

  static Company fromJson(Map<String, dynamic> json) => Company(
        id: json['id'] as String,
        name: json['name'] as String? ?? 'Unknown',
        domain: _str(json['domain']),
        website: _str(json['website']),
        careersUrl: _str(json['careers_url']),
        location: _str(json['location']),
        industry: _str(json['industry']),
        employeeCount: json['employee_count'] as int?,
        playStoreDevId: _str(json['play_store_dev_id']),
        appPackageId: _str(json['app_package_id']),
        evidence: _evidence(json['stack_signals']),
        hiringSignals: _signals(json['intent_signals']),
      );

  static List<Company> listFromJson(Object? raw) {
    if (raw is! List<dynamic>) return const <Company>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .toList();
  }

  /// Only Flutter-bearing evidence reaches the UI. A company can carry stack
  /// evidence for unrelated technologies — that is not why it is in this list,
  /// and showing "Hired for React" under a Flutter heading would be a lie.
  static List<FlutterEvidence> _evidence(Object? raw) {
    if (raw is! List<dynamic>) return const <FlutterEvidence>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) {
          final techs = _techs(m['technologies']);
          return FlutterEvidence(
            kind: EvidenceKind.fromWire(m['source_type'] as String?),
            sourceUrl: _str(m['source_url']),
            note: _str(m['raw_evidence']),
            technologies: techs,
            observedAt: _date(m['detected_at']),
          );
        })
        .where((e) =>
            e.technologies.containsKey('flutter') ||
            e.technologies.containsKey('dart'))
        .toList();
  }

  static List<HiringSignal> _signals(Object? raw) {
    if (raw is! List<dynamic>) return const <HiringSignal>[];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => HiringSignal(
              kind: HiringSignalKind.fromWire(m['signal_type'] as String?),
              source: m['source'] as String? ?? '',
              confidence: _num(m['confidence']),
              observedAt: _date(m['detected_at']),
            ))
        .toList();
  }

  static Map<String, double> _techs(Object? raw) {
    if (raw is! Map) return const <String, double>{};
    final out = <String, double>{};
    raw.forEach((key, value) {
      if (key is String && value is num) out[key] = value.toDouble();
    });
    return out;
  }

  /// Blank strings arrive from feed data as often as nulls; both mean absent.
  static String? _str(Object? v) {
    if (v is! String) return null;
    final trimmed = v.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static double _num(Object? v) => v is num ? v.toDouble() : 0.0;

  static DateTime _date(Object? v) => v is String
      ? (DateTime.tryParse(v)?.toLocal() ?? DateTime.now())
      : DateTime.now();
}
