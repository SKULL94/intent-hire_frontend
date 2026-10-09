import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/widgets/tech_chip.dart';
import '../../domain/entities/job.dart';

class JobCard extends StatelessWidget {
  final Job job;

  /// Lowercased skill names from the user's profile, used to highlight the
  /// technologies this posting asks for that they already have.
  final Set<String> userSkills;

  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.userSkills = const {},
    this.onTap,
  });

  /// Technologies the user already has come first — those are the reason this
  /// posting is worth their attention.
  List<(String, double)> _chipsToShow() {
    final ranked = job.rankedTechnologies;
    final matched = ranked.where((t) => userSkills.contains(t.$1.toLowerCase()));
    final rest = ranked.where((t) => !userSkills.contains(t.$1.toLowerCase()));
    return [...matched, ...rest].take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chips = _chipsToShow();
    final posted = job.postedAt;

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
                          job.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          job.company.name,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (job.salaryLabel != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      job.salaryLabel!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _Meta(
                    icon: Icons.place_outlined,
                    label: job.locationLabel,
                  ),
                  if (job.isRemote)
                    const _Meta(
                        icon: Icons.wifi, label: 'Remote', highlight: true),
                  if (job.minYearsExperience != null)
                    _Meta(
                      icon: Icons.work_history_outlined,
                      label: job.minYearsExperience == 0
                          ? 'Entry level'
                          : '${job.minYearsExperience}+ yrs',
                    ),
                  if (posted != null)
                    _Meta(
                      icon: Icons.schedule,
                      label: timeago.format(posted, locale: 'en_short'),
                    ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _Meta({required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        highlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
