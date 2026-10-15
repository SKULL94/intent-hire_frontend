import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/company.dart';

/// One line of "why this company is in the list".
///
/// Proof-grade evidence (something they shipped) reads green; inferred
/// evidence (a job title) reads neutral. The distinction is the whole point:
/// the list used to be full of companies whose only evidence was a passing
/// mention in a job description.
class EvidenceBadge extends StatelessWidget {
  final FlutterEvidence evidence;
  final bool compact;

  const EvidenceBadge({
    super.key,
    required this.evidence,
    this.compact = false,
  });

  IconData get _icon => switch (evidence.kind) {
        EvidenceKind.apk => Icons.phone_android,
        EvidenceKind.pubDev => Icons.inventory_2_outlined,
        EvidenceKind.github => Icons.code,
        EvidenceKind.jobTitle => Icons.badge_outlined,
        EvidenceKind.blog => Icons.article_outlined,
        EvidenceKind.unknown => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isProof = evidence.kind.isProof;
    final tint = isProof ? AppColors.success : cs.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_icon, size: compact ? 14 : 18, color: tint),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      evidence.kind.label,
                      style: (compact ? text.bodySmall : text.bodyMedium)
                          ?.copyWith(
                        color: isProof ? tint : cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isProof) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.verified, size: 13, color: tint),
                  ],
                ],
              ),
              if (!compact && evidence.kind.explanation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    evidence.kind.explanation!,
                    style: text.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
