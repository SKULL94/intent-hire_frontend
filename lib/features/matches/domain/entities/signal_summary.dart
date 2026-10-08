import 'package:equatable/equatable.dart';

import '../../../../core/widgets/signal_icon.dart';

/// One piece of evidence behind a match, from `match.top_signals`.
class SignalSummary extends Equatable {
  final String signalType;
  final String source;
  final double confidence;
  final DateTime detectedAt;

  const SignalSummary({
    required this.signalType,
    required this.source,
    required this.confidence,
    required this.detectedAt,
  });

  SignalIconKind get iconKind => switch (signalType) {
        'ats_job' => SignalIconKind.atsJob,
        'funding' => SignalIconKind.funding,
        'news' => SignalIconKind.news,
        'hn_whos_hiring' => SignalIconKind.hnWhosHiring,
        _ => SignalIconKind.githubActivity,
      };

  String get label => switch (signalType) {
        'ats_job' => 'Open roles posted',
        'funding' => 'Funding announced',
        'news' => 'In the news',
        'hn_whos_hiring' => 'Posted on HN hiring',
        'github_activity' => 'GitHub activity',
        _ => signalType,
      };

  @override
  List<Object?> get props => [signalType, source, confidence, detectedAt];
}
