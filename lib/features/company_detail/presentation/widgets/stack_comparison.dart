import 'package:flutter/material.dart';

import '../../../../core/widgets/tech_chip.dart';
import '../../domain/entities/company_detail.dart';

/// Splits the company's detected stack into "you already have this" and
/// "you don't", which is the question a candidate actually has.
class StackComparison extends StatelessWidget {
  final CompanyDetail company;
  final Set<String> userSkills;

  const StackComparison({
    super.key,
    required this.company,
    required this.userSkills,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (matched, gaps) = company.splitBySkills(userSkills);

    if (matched.isEmpty && gaps.isEmpty) {
      return Text(
        'No stack detected yet. We infer stacks from public repos, job '
        'descriptions, and site fingerprints — this company has none of those '
        'readable so far.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (matched.isNotEmpty) ...[
          Text(
            'You match on ${matched.length}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (tech, confidence) in matched)
                TechChip(tech: tech, confidence: confidence, matched: true),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (gaps.isNotEmpty) ...[
          Text(
            matched.isEmpty ? 'Their stack' : 'Also in their stack',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (tech, confidence) in gaps.take(24))
                TechChip(tech: tech, confidence: confidence),
            ],
          ),
          if (gaps.length > 24)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${gaps.length - 24} more',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ],
    );
  }
}
