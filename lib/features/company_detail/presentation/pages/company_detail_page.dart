import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/score_badge.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/company_detail_bloc.dart';
import '../widgets/signal_timeline.dart';
import '../widgets/stack_comparison.dart';

class CompanyDetailPage extends StatelessWidget {
  final String companyId;

  const CompanyDetailPage({super.key, required this.companyId});

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSkills =
        context.select<ProfileBloc, Set<String>>((b) => b.state.skillNames);

    return BlocBuilder<CompanyDetailBloc, CompanyDetailStateData>(
      builder: (context, state) {
        final company = state.company;

        if (state.status == CompanyDetailStatus.failure) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load company',
              message: state.errorMessage,
              action: FilledButton.tonal(
                onPressed: () => context
                    .read<CompanyDetailBloc>()
                    .add(CompanyDetailRequested(companyId)),
                child: const Text('Retry'),
              ),
            ),
          );
        }

        if (company == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(title: Text(company.name)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [company.industry, company.location]
                              .whereType<String>()
                              .join(' · '),
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (company.employeeCount != null)
                          Text(
                            '~${company.employeeCount} employees',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Hiring intent ${company.intentScore.round()} · '
                          '${company.signalCount} signal'
                          '${company.signalCount == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ScoreBadge(score: company.intentScore, size: 60),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (company.careersUrl != null)
                    FilledButton.icon(
                      onPressed: () => _open(company.careersUrl!),
                      icon: const Icon(Icons.work_outline, size: 18),
                      label: const Text('Open roles'),
                    ),
                  if (company.website != null || company.domain != null)
                    OutlinedButton.icon(
                      onPressed: () => _open(
                        company.website ?? 'https://${company.domain}',
                      ),
                      icon: const Icon(Icons.language, size: 18),
                      label: const Text('Website'),
                    ),
                  if (company.githubOrg != null)
                    OutlinedButton.icon(
                      onPressed: () =>
                          _open('https://github.com/${company.githubOrg}'),
                      icon: const Icon(Icons.code, size: 18),
                      label: const Text('GitHub'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Stack comparison', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              StackComparison(company: company, userSkills: userSkills),
              const SizedBox(height: 24),
              Text('Why we think they are hiring',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              SignalTimeline(signals: company.intentSignals),
              if (company.stackSignals.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Where the stack came from',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final observation in company.stackSignals.take(8))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(observation.sourceLabel),
                    subtitle: Text(
                      observation.technologies.keys.take(8).join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: observation.sourceUrl == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.open_in_new, size: 18),
                            onPressed: () => _open(observation.sourceUrl!),
                          ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
