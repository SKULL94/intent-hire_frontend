import 'package:equatable/equatable.dart';

import 'company_summary.dart';
import 'signal_summary.dart';

enum MatchStatus { newMatch, viewed, saved, applied, dismissed }

extension MatchStatusWire on MatchStatus {
  /// The backend uses snake_case strings; `new` is reserved in Dart.
  String get wire => switch (this) {
        MatchStatus.newMatch => 'new',
        MatchStatus.viewed => 'viewed',
        MatchStatus.saved => 'saved',
        MatchStatus.applied => 'applied',
        MatchStatus.dismissed => 'dismissed',
      };

  static MatchStatus parse(String? value) => switch (value) {
        'viewed' => MatchStatus.viewed,
        'saved' => MatchStatus.saved,
        'applied' => MatchStatus.applied,
        'dismissed' => MatchStatus.dismissed,
        _ => MatchStatus.newMatch,
      };
}

class Match extends Equatable {
  final String id;
  final String companyId;

  /// `0.4 * intentScore + 0.6 * techFit * 100`, so 0..100.
  final double score;

  /// Cosine similarity of the user's skills against the company stack, 0..1.
  final double techFit;

  /// How strongly the company looks like it is hiring right now, 0..100.
  final double intentScore;

  final List<SignalSummary> topSignals;
  final MatchStatus status;
  final DateTime matchedAt;
  final CompanySummary company;

  const Match({
    required this.id,
    required this.companyId,
    required this.score,
    required this.techFit,
    required this.intentScore,
    required this.status,
    required this.matchedAt,
    required this.company,
    this.topSignals = const [],
  });

  Match copyWith({MatchStatus? status}) => Match(
        id: id,
        companyId: companyId,
        score: score,
        techFit: techFit,
        intentScore: intentScore,
        status: status ?? this.status,
        matchedAt: matchedAt,
        company: company,
        topSignals: topSignals,
      );

  /// Which of the user's skills this company's stack actually covers.
  Set<String> matchedSkills(Iterable<String> userSkills) {
    final stack = company.stackFingerprint.keys.map((k) => k.toLowerCase()).toSet();
    return userSkills.map((s) => s.toLowerCase()).where(stack.contains).toSet();
  }

  @override
  List<Object?> get props => [
        id,
        companyId,
        score,
        techFit,
        intentScore,
        topSignals,
        status,
        matchedAt,
        company,
      ];
}
