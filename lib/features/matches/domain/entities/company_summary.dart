import 'package:equatable/equatable.dart';

/// The slice of a company carried alongside a match.
///
/// `GET /api/v1/matches` embeds the company and its score so the list renders
/// without an N+1 fetch per card.
class CompanySummary extends Equatable {
  final String id;
  final String name;
  final String? domain;
  final String? careersUrl;
  final String? atsType;
  final String? industry;
  final String? location;
  final String? logoUrl;
  final int? employeeCount;

  /// Technology -> confidence (0..1), aggregated across every stack signal.
  final Map<String, double> stackFingerprint;
  final int signalCount;
  final String? strongestSignal;

  const CompanySummary({
    required this.id,
    required this.name,
    this.domain,
    this.careersUrl,
    this.atsType,
    this.industry,
    this.location,
    this.logoUrl,
    this.employeeCount,
    this.stackFingerprint = const {},
    this.signalCount = 0,
    this.strongestSignal,
  });

  /// True when the company exposes a job board we can read open roles from.
  /// `ats_type == 'other'` means we found the careers page but not an API.
  bool get hasReachableAts => atsType != null && atsType != 'other';

  /// Technologies ordered strongest-first, for compact display.
  List<(String, double)> get rankedStack {
    final entries = stackFingerprint.entries.map((e) => (e.key, e.value)).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return entries;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        domain,
        careersUrl,
        atsType,
        industry,
        location,
        logoUrl,
        employeeCount,
        stackFingerprint,
        signalCount,
        strongestSignal,
      ];
}
