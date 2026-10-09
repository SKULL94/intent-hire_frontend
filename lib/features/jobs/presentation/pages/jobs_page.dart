import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../bloc/jobs_bloc.dart';
import '../widgets/job_card.dart';
import '../widgets/job_filter_sheet.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  Future<void> _openPosting(BuildContext context, Job job) async {
    final messenger = ScaffoldMessenger.of(context);
    final raw = job.url;
    if (raw == null || raw.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This posting has no link')),
      );
      return;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open $raw')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The user's own skills, so a posting can highlight what they already have.
    final userSkills =
        context.select<ProfileBloc, Set<String>>((b) => b.state.skillNames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          BlocBuilder<JobsBloc, JobsStateData>(
            buildWhen: (p, c) => p.filter.sort != c.filter.sort,
            builder: (context, state) => PopupMenuButton<JobSort>(
              tooltip: 'Sort',
              icon: const Icon(Icons.swap_vert),
              initialValue: state.filter.sort,
              onSelected: (sort) =>
                  context.read<JobsBloc>().add(JobSortChanged(sort)),
              itemBuilder: (_) => [
                for (final sort in JobSort.values)
                  PopupMenuItem(value: sort, child: Text(sort.label)),
              ],
            ),
          ),
          BlocBuilder<JobsBloc, JobsStateData>(
            buildWhen: (p, c) => p.filter != c.filter,
            builder: (context, state) {
              final count = state.filter.activeCount;
              return IconButton(
                tooltip: 'Filter',
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: Icon(
                    state.filter.isDefault
                        ? Icons.filter_list
                        : Icons.filter_list_alt,
                  ),
                ),
                onPressed: () async {
                  final bloc = context.read<JobsBloc>();
                  final updated = await JobFilterSheet.show(
                    context,
                    state.filter,
                    availableTechnologies: bloc.state.availableTechnologies,
                  );
                  if (updated != null) bloc.add(JobFilterChanged(updated));
                },
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<JobsBloc, JobsStateData>(
        listenWhen: (p, c) =>
            c.status == JobsStatus.failure && p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == JobsStatus.initial ||
              (state.status == JobsStatus.loading && state.jobs.isEmpty)) {
            return const LoadingShimmer();
          }

          if (state.showEmptyState) {
            return EmptyState(
              icon: Icons.work_outline,
              title: 'No jobs match these filters',
              message: state.filter.isDefault
                  ? 'Nothing has been collected yet. Pull to refresh.'
                  : 'Try removing a technology, widening the location, or '
                      'raising the experience ceiling.',
              action: FilledButton.tonal(
                onPressed: () => context
                    .read<JobsBloc>()
                    .add(const JobFilterChanged(JobFilter())),
                child: const Text('Clear filters'),
              ),
            );
          }

          return Column(
            children: [
              _ActiveFilterBar(state: state),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<JobsBloc>().add(const JobsRefreshRequested());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: state.jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return JobCard(
                        job: job,
                        userSkills: userSkills,
                        onTap: () => _openPosting(context, job),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Result count plus one-tap technology toggles, so the common adjustment
/// does not require opening the sheet.
class _ActiveFilterBar extends StatelessWidget {
  final JobsStateData state;

  const _ActiveFilterBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = state.filter;

    final locationSummary = <String>[
      ...filter.locations.map(JobLocations.label),
      if (filter.includeRemote) 'Remote',
    ].join(' · ');

    // Selected first so an active filter is never scrolled out of reach.
    final chips = <String>{
      ...filter.technologies,
      ...state.availableTechnologies,
    }.take(10).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${state.jobs.length} ${state.jobs.length == 1 ? "job" : "jobs"}',
                style: theme.textTheme.titleSmall,
              ),
              if (locationSummary.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationSummary,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ] else
                const Spacer(),
              if (state.isBusy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (chips.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final tech = chips[index];
                  return Align(
                    child: FilterChip(
                      label: Text(tech),
                      selected: filter.technologies.contains(tech),
                      visualDensity: VisualDensity.compact,
                      onSelected: (_) => context
                          .read<JobsBloc>()
                          .add(JobTechnologyToggled(tech)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
