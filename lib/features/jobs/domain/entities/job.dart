import 'package:equatable/equatable.dart';

/// Normalized location keys the backend produces (`app/utils/job_parser.py`).
/// NCR satellite towns all collapse into `delhi_ncr`, because that is how
/// people search — nobody filters for "Ghaziabad" specifically.
class JobLocations {
  const JobLocations._();

  static const String delhiNcr = 'delhi_ncr';
  static const String bengaluru = 'bengaluru';
  static const String mumbai = 'mumbai';
  static const String pune = 'pune';
  static const String hyderabad = 'hyderabad';
  static const String chennai = 'chennai';
  static const String kolkata = 'kolkata';
  static const String ahmedabad = 'ahmedabad';
  static const String indiaOther = 'india_other';
  static const String remote = 'remote';

  /// Display order: NCR first because it is the common case for this user.
  static const List<String> all = [
    delhiNcr,
    bengaluru,
    mumbai,
    pune,
    hyderabad,
    chennai,
    kolkata,
    ahmedabad,
    indiaOther,
  ];

  static const Map<String, String> labels = {
    delhiNcr: 'Delhi NCR',
    bengaluru: 'Bengaluru',
    mumbai: 'Mumbai',
    pune: 'Pune',
    hyderabad: 'Hyderabad',
    chennai: 'Chennai',
    kolkata: 'Kolkata',
    ahmedabad: 'Ahmedabad',
    indiaOther: 'Elsewhere in India',
    remote: 'Remote',
  };

  static String label(String? key) => labels[key] ?? 'Unknown';
}

/// The slice of a company carried alongside a job.
class JobCompany extends Equatable {
  final String id;
  final String name;
  final String? domain;
  final String? logoUrl;
  final String? careersUrl;

  const JobCompany({
    required this.id,
    required this.name,
    this.domain,
    this.logoUrl,
    this.careersUrl,
  });

  @override
  List<Object?> get props => [id, name, domain, logoUrl, careersUrl];
}

class Job extends Equatable {
  final String id;
  final String companyId;

  /// Which collector produced this: an ATS name, or 'adzuna'.
  final String source;

  final String title;
  final String? url;
  final String? department;
  final String? description;

  /// As published, e.g. "Gurgaon, Haryana".
  final String? locationRaw;

  /// One of [JobLocations], or null when the location could not be mapped.
  final String? locationNormalized;

  final bool isRemote;

  /// Technology -> confidence, detected from the posting's own words.
  final Map<String, double> technologies;

  final int? minYearsExperience;
  final double? salaryMin;
  final double? salaryMax;
  final String? contractTime;

  final DateTime? postedAt;
  final DateTime lastSeenAt;

  final JobCompany company;

  /// The employer's overall hiring-intent score, so a job can be judged by
  /// more than its own posting date.
  final double? companyIntentScore;

  const Job({
    required this.id,
    required this.companyId,
    required this.source,
    required this.title,
    required this.lastSeenAt,
    required this.company,
    this.url,
    this.department,
    this.description,
    this.locationRaw,
    this.locationNormalized,
    this.isRemote = false,
    this.technologies = const {},
    this.minYearsExperience,
    this.salaryMin,
    this.salaryMax,
    this.contractTime,
    this.postedAt,
    this.companyIntentScore,
  });

  /// Technologies ordered strongest-first, for compact display.
  List<(String, double)> get rankedTechnologies {
    final entries = technologies.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return entries;
  }

  /// Which of the user's skills this posting actually asks for.
  Set<String> matchedSkills(Iterable<String> userSkills) {
    final asked = technologies.keys.map((k) => k.toLowerCase()).toSet();
    return userSkills.map((s) => s.toLowerCase()).where(asked.contains).toSet();
  }

  bool get hasSalary => salaryMin != null && salaryMax != null;

  /// Indian salaries are quoted in lakhs; raw rupees are unreadable on a card.
  String? get salaryLabel {
    if (!hasSalary) return null;
    final min = (salaryMin! / 100000).round();
    final max = (salaryMax! / 100000).round();
    if (min == max) return '₹${min}L';
    return '₹$min–${max}L';
  }

  String get locationLabel {
    if (locationRaw != null && locationRaw!.isNotEmpty) return locationRaw!;
    if (locationNormalized != null) return JobLocations.label(locationNormalized);
    return 'Location not stated';
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        source,
        title,
        url,
        locationRaw,
        locationNormalized,
        isRemote,
        technologies,
        minYearsExperience,
        salaryMin,
        salaryMax,
        contractTime,
        postedAt,
        lastSeenAt,
        company,
        companyIntentScore,
      ];
}
