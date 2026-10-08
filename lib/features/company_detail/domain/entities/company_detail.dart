import 'package:equatable/equatable.dart';

import '../../../matches/domain/entities/signal_summary.dart';

/// A technology observed at a company, with where the observation came from.
class StackObservation extends Equatable {
  final String sourceType; // github | ats_job_nlp | wappalyzer | hn_whos_hiring
  final String? sourceUrl;
  final Map<String, double> technologies;
  final DateTime detectedAt;

  const StackObservation({
    required this.sourceType,
    required this.technologies,
    required this.detectedAt,
    this.sourceUrl,
  });

  String get sourceLabel => switch (sourceType) {
        'github' => 'GitHub dependencies',
        'ats_job_nlp' => 'Job description',
        'wappalyzer' => 'Website fingerprint',
        'hn_whos_hiring' => 'HN hiring post',
        _ => sourceType,
      };

  @override
  List<Object?> get props => [sourceType, sourceUrl, technologies, detectedAt];
}

class CompanyDetail extends Equatable {
  final String id;
  final String name;
  final String? domain;
  final String? careersUrl;
  final String? website;
  final String? atsType;
  final String? githubOrg;
  final String? industry;
  final String? location;
  final int? employeeCount;

  final double intentScore;
  final int signalCount;
  final String? strongestSignal;
  final Map<String, double> stackFingerprint;

  final List<SignalSummary> intentSignals;
  final List<StackObservation> stackSignals;

  const CompanyDetail({
    required this.id,
    required this.name,
    this.domain,
    this.careersUrl,
    this.website,
    this.atsType,
    this.githubOrg,
    this.industry,
    this.location,
    this.employeeCount,
    this.intentScore = 0,
    this.signalCount = 0,
    this.strongestSignal,
    this.stackFingerprint = const {},
    this.intentSignals = const [],
    this.stackSignals = const [],
  });

  List<(String, double)> get rankedStack {
    final entries =
        stackFingerprint.entries.map((e) => (e.key, e.value)).toList()
          ..sort((a, b) => b.$2.compareTo(a.$2));
    return entries;
  }

  /// Splits the stack into what the user already has and what they don't,
  /// which is the comparison the detail screen is for.
  (List<(String, double)> matched, List<(String, double)> gaps) splitBySkills(
    Set<String> userSkills,
  ) {
    final matched = <(String, double)>[];
    final gaps = <(String, double)>[];
    for (final tech in rankedStack) {
      if (userSkills.contains(tech.$1.toLowerCase())) {
        matched.add(tech);
      } else {
        gaps.add(tech);
      }
    }
    return (matched, gaps);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        domain,
        careersUrl,
        website,
        atsType,
        githubOrg,
        industry,
        location,
        employeeCount,
        intentScore,
        signalCount,
        strongestSignal,
        stackFingerprint,
        intentSignals,
        stackSignals,
      ];
}
