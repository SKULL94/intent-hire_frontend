import 'package:equatable/equatable.dart';

/// Why we believe a company builds in Flutter.
///
/// Ordered by how much it proves. Only title-grade job evidence and shipped
/// artefacts survive collection — a description that merely mentions Flutter
/// is not evidence, and used to produce companies like Airbnb and a gambling
/// group named "Flutter International".
enum EvidenceKind {
  apk('apk', 'Flutter in shipped app', 'Their Play Store app contains the Flutter engine'),
  pubDev('pubdev', 'Publishes Dart packages', 'Verified publisher on pub.dev'),
  github('github', 'Flutter in source', 'A public repo declares Flutter in pubspec.yaml'),
  jobTitle('ats_job_nlp', 'Hired for Flutter', 'A job posting titled for Flutter or Dart'),
  blog('blog', 'Wrote about Flutter', 'Their engineering blog discusses Flutter'),
  unknown('unknown', 'Other evidence', null);

  const EvidenceKind(this.wireName, this.label, this.explanation);

  final String wireName;
  final String label;
  final String? explanation;

  /// Proof-grade evidence comes from something the company shipped, which
  /// cannot be a coincidence of wording.
  bool get isProof => this == apk || this == pubDev || this == github;

  static EvidenceKind fromWire(String? raw) => values.firstWhere(
        (k) => k.wireName == raw,
        orElse: () => unknown,
      );
}

/// Why we believe a company is about to hire, with how far ahead it fires.
enum HiringSignalKind {
  funding('funding', 'Raised funding', '30–90 days'),
  news('news', 'Expansion announced', '45–180 days'),
  newApp('new_app', 'Launched a Flutter app', '7–60 days'),
  sdkJump('sdk_jump', 'Modernising their app', '7–60 days'),
  posting('ats_job', 'Posting roles now', 'hiring now'),
  unknown('unknown', 'Hiring signal', null);

  const HiringSignalKind(this.wireName, this.label, this.leadTime);

  final String wireName;
  final String label;
  final String? leadTime;

  static HiringSignalKind fromWire(String? raw) => values.firstWhere(
        (k) => k.wireName == raw,
        orElse: () => unknown,
      );
}

class FlutterEvidence extends Equatable {
  final EvidenceKind kind;
  final String? sourceUrl;
  final String? note;
  final Map<String, double> technologies;
  final DateTime observedAt;

  const FlutterEvidence({
    required this.kind,
    required this.observedAt,
    this.sourceUrl,
    this.note,
    this.technologies = const {},
  });

  double get flutterConfidence {
    final flutter = technologies['flutter'] ?? 0;
    final dart = technologies['dart'] ?? 0;
    return flutter > dart ? flutter : dart;
  }

  @override
  List<Object?> get props => [kind, sourceUrl, note, technologies, observedAt];
}

class HiringSignal extends Equatable {
  final HiringSignalKind kind;
  final String source;
  final double confidence;
  final DateTime observedAt;

  const HiringSignal({
    required this.kind,
    required this.source,
    required this.confidence,
    required this.observedAt,
  });

  /// The source is a URL for news and funding, and an opaque token
  /// ("adzuna:flutter_jobs") for everything else.
  String? get url => source.startsWith('http') ? source : null;

  @override
  List<Object?> get props => [kind, source, confidence, observedAt];
}

/// A company in the registry: one row of the only question this app answers.
class Company extends Equatable {
  final String id;
  final String name;
  final String? domain;
  final String? website;
  final String? careersUrl;
  final String? location;
  final String? industry;
  final int? employeeCount;
  final String? playStoreDevId;
  final String? appPackageId;

  final List<FlutterEvidence> evidence;
  final List<HiringSignal> hiringSignals;

  const Company({
    required this.id,
    required this.name,
    this.domain,
    this.website,
    this.careersUrl,
    this.location,
    this.industry,
    this.employeeCount,
    this.playStoreDevId,
    this.appPackageId,
    this.evidence = const [],
    this.hiringSignals = const [],
  });

  bool get hasProof => evidence.any((e) => e.kind.isProof);

  /// Strongest evidence first, so the card can show one line that matters.
  List<FlutterEvidence> get rankedEvidence {
    final sorted = [...evidence]..sort((a, b) {
        if (a.kind.isProof != b.kind.isProof) return a.kind.isProof ? -1 : 1;
        return b.observedAt.compareTo(a.observedAt);
      });
    return sorted;
  }

  FlutterEvidence? get bestEvidence =>
      rankedEvidence.isEmpty ? null : rankedEvidence.first;

  List<HiringSignal> get rankedSignals {
    final sorted = [...hiringSignals]
      ..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return sorted;
  }

  HiringSignal? get latestSignal =>
      rankedSignals.isEmpty ? null : rankedSignals.first;

  /// Technologies seen across all evidence, strongest confidence per name.
  List<(String, double)> get technologies {
    final merged = <String, double>{};
    for (final e in evidence) {
      e.technologies.forEach((tech, conf) {
        final seen = merged[tech] ?? 0;
        if (conf > seen) merged[tech] = conf;
      });
    }
    final entries = merged.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return entries;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        domain,
        website,
        careersUrl,
        location,
        industry,
        employeeCount,
        playStoreDevId,
        appPackageId,
        evidence,
        hiringSignals,
      ];
}
