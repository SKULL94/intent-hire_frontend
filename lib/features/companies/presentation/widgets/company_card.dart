import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/company.dart';
import 'evidence_badge.dart';

class CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;

  const CompanyCard({
    super.key,
    required this.company,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final evidence = company.bestEvidence;
    final signal = company.latestSignal;

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
                  _Avatar(name: company.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: text.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (company.domain != null ||
                            company.location != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            [company.domain, company.location]
                                .whereType<String>()
                                .join(' · '),
                            style: text.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (company.hasProof)
                    const Icon(Icons.verified,
                        size: 18, color: AppColors.success),
                ],
              ),
              if (evidence != null) ...[
                const SizedBox(height: 12),
                EvidenceBadge(evidence: evidence, compact: true),
              ],
              if (signal != null) ...[
                const SizedBox(height: 8),
                _SignalLine(signal: signal),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SignalLine extends StatelessWidget {
  final HiringSignal signal;
  const _SignalLine({required this.signal});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        const Icon(Icons.trending_up, size: 14, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${signal.kind.label} · ${timeago.format(signal.observedAt)}',
            style: text.bodySmall?.copyWith(color: AppColors.warning),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Feed names can start with punctuation or a digit; fall back rather than
    // crash on an empty string.
    final letter = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
