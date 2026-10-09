import '../../domain/entities/job.dart';

/// Parses `GET /api/v1/jobs`.
///
/// Defensive about types throughout: `technologies` confidences arrive as
/// either int or double depending on the value, salaries may be absent, and
/// `is_remote` is nullable in the schema because a posting whose location we
/// could not read is "unknown", not "not remote".
class JobModel {
  const JobModel._();

  static Job fromJson(Map<String, dynamic> json) => Job(
        id: json['id'] as String,
        companyId: json['company_id'] as String,
        source: json['source'] as String? ?? 'unknown',
        title: json['title'] as String? ?? 'Untitled role',
        url: json['url'] as String?,
        department: json['department'] as String?,
        description: json['description'] as String?,
        locationRaw: json['location_raw'] as String?,
        locationNormalized: json['location_normalized'] as String?,
        isRemote: json['is_remote'] as bool? ?? false,
        technologies: _technologies(json['technologies']),
        minYearsExperience: _int(json['min_years_experience']),
        salaryMin: _double(json['salary_min']),
        salaryMax: _double(json['salary_max']),
        contractTime: json['contract_time'] as String?,
        postedAt: _date(json['posted_at']),
        lastSeenAt: _date(json['last_seen_at']) ?? DateTime.now().toUtc(),
        company: _company(json['company']),
        companyIntentScore: _double(json['company_intent_score']),
      );

  static JobCompany _company(dynamic raw) {
    final map = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
    return JobCompany(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown company',
      domain: map['domain'] as String?,
      logoUrl: map['logo_url'] as String?,
      careersUrl: map['careers_url'] as String?,
    );
  }

  static Map<String, double> _technologies(dynamic raw) {
    if (raw is! Map) return const {};
    final out = <String, double>{};
    raw.forEach((key, value) {
      final confidence = _double(value);
      if (key is String && confidence != null) out[key] = confidence;
    });
    return out;
  }

  static double? _double(dynamic v) => switch (v) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s),
        _ => null,
      };

  static int? _int(dynamic v) => switch (v) {
        final num n => n.toInt(),
        final String s => int.tryParse(s),
        _ => null,
      };

  static DateTime? _date(dynamic v) {
    if (v is! String || v.isEmpty) return null;
    return DateTime.tryParse(v)?.toLocal();
  }
}
