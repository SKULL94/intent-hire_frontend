import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/match.dart';
import '../bloc/matches_bloc.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/match_card.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The user's skills live in ProfileBloc (provided above the nav shell) so
    // cards can highlight the technologies they have in common with a company.
    final userSkills =
        context.select<ProfileBloc, Set<String>>((b) => b.state.skillNames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          BlocBuilder<MatchesBloc, MatchesStateData>(
            buildWhen: (p, c) => p.filter != c.filter,
            builder: (context, state) => IconButton(
              tooltip: 'Filter',
              icon: Icon(
                state.filter.isDefault
                    ? Icons.filter_list
                    : Icons.filter_list_alt,
              ),
              onPressed: () async {
                final bloc = context.read<MatchesBloc>();
                final updated = await FilterSheet.show(context, state.filter);
                if (updated != null) bloc.add(MatchFilterChanged(updated));
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<MatchesBloc, MatchesStateData>(
        listenWhen: (p, c) =>
            c.status == MatchesStatus.failure && p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == MatchesStatus.initial ||
              (state.status == MatchesStatus.loading && state.matches.isEmpty)) {
            return const LoadingShimmer();
          }

          if (state.showEmptyState) {
            return EmptyState(
              icon: Icons.radar,
              title: state.filter.isDefault
                  ? 'No matches yet'
                  : 'No matches at this threshold',
              message: state.filter.isDefault
                  ? 'We track companies daily. Add more skills to your profile to widen the net.'
                  : 'Try lowering the minimum score or stack fit.',
              action: FilledButton.tonal(
                onPressed: () => context
                    .read<MatchesBloc>()
                    .add(const MatchesRefreshRequested()),
                child: const Text('Refresh'),
              ),
            );
          }

          final matches = state.visible;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MatchesBloc>().add(const MatchesRefreshRequested());
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final match = matches[index];
                return Dismissible(
                  key: ValueKey(match.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.visibility_off_outlined),
                  ),
                  onDismissed: (_) => context.read<MatchesBloc>().add(
                        MatchStatusChanged(match.id, MatchStatus.dismissed),
                      ),
                  child: MatchCard(
                    match: match,
                    userSkills: userSkills,
                    onTap: () =>
                        context.push(RoutePaths.companyDetail(match.companyId)),
                    onSave: () => context.read<MatchesBloc>().add(
                          MatchStatusChanged(
                            match.id,
                            match.status == MatchStatus.saved
                                ? MatchStatus.viewed
                                : MatchStatus.saved,
                          ),
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
