import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/score_badge.dart';
import '../../../../core/widgets/signal_icon.dart';
import '../../../../core/widgets/tech_chip.dart';
import '../../domain/entities/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;

  /// Lowercased skill names from the user's profile, used to highlight the
  /// technologies this company has in common with them.
  final Set<String> userSkills;

  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const MatchCard({
    super.key,
    required this.match,
    this.userSkills = const {},
    this.onTap,
    this.onSave,
  });

  /// Overlapping technologies first (those are the reason this is a match),
  /// then the strongest remaining ones to fill out the picture.
  List<(String, double)> _chipsToShow() {
    final ranked = match.company.rankedStack;
    final overlap = ranked.where((t) => userSkills.contains(t.$1.toLowerCase()));
    final rest = ranked.where((t) => !userSkills.contains(t.$1.toLowerCase()));
    return [...overlap, ...rest].take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final company = match.company;
    final chips = _chipsToShow();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [company.industry, company.location]
                              .whereType<String>()
                              .join(' · '),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ScoreBadge(score: match.score),
                ],
              ),
              const SizedBox(height: 12),
              _MetricRow(
                techFit: match.techFit,
                intentScore: match.intentScore,
                matchedCount: chips.where((c) => userSkills.contains(c.$1)).length,
              ),
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final (tech, confidence) in chips)
                      TechChip(
                        tech: tech,
                        confidence: confidence,
                        matched: userSkills.contains(tech.toLowerCase()),
                      ),
                  ],
                ),
              ],
              if (match.topSignals.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                for (final signal in match.topSignals.take(2))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SignalIcon(kind: signal.iconKind, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            signal.label,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          timeago.format(signal.detectedAt, locale: 'en_short'),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
              ],
              if (!company.hasReachableAts)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'No readable job board — intent is inferred from other signals',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              if (onSave != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onSave,
                    icon: Icon(
                      match.status == MatchStatus.saved
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: Text(
                      match.status == MatchStatus.saved ? 'Saved' : 'Save',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final double techFit;
  final double intentScore;
  final int matchedCount;

  const _MetricRow({
    required this.techFit,
    required this.intentScore,
    required this.matchedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget metric(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(value, style: theme.textTheme.titleSmall),
            ],
          ),
        );

    return Row(
      children: [
        metric('Stack fit', '${(techFit * 100).round()}%'),
        metric('Hiring intent', intentScore.round().toString()),
        if (matchedCount > 0)
          metric('Your skills', '$matchedCount matched')
        else
          const Spacer(),
      ],
    );
  }
}
