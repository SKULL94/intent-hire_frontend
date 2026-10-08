import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/signal_icon.dart';
import '../../../matches/domain/entities/signal_summary.dart';

/// Reverse-chronological list of the intent evidence behind a company's score.
class SignalTimeline extends StatelessWidget {
  final List<SignalSummary> signals;

  const SignalTimeline({super.key, required this.signals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (signals.isEmpty) {
      return Text(
        'No hiring signals recorded yet.',
        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, signal) in signals.indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SignalIcon(kind: signal.iconKind, size: 18),
                  if (index != signals.length - 1)
                    Container(
                      width: 1,
                      height: 36,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: cs.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(signal.label, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${signal.source} · '
                        '${(signal.confidence * 100).round()}% confidence · '
                        '${timeago.format(signal.detectedAt)}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
