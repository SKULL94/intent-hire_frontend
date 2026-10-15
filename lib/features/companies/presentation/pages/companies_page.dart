import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/companies_bloc.dart';
import '../widgets/company_card.dart';
import '../widgets/filter_bar.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});

  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<CompaniesBloc>().add(const CompaniesNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CompaniesBloc, CompaniesStateData>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flutter employers', style: text.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(state),
                        style: text.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                FilterBar(
                  filter: state.filter,
                  onChanged: (f) => context
                      .read<CompaniesBloc>()
                      .add(CompaniesFilterChanged(f)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => context
                        .read<CompaniesBloc>()
                        .add(CompaniesSearchChanged(v)),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Filter by name, domain or city',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: state.search.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<CompaniesBloc>()
                                    .add(const CompaniesSearchChanged(''));
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  String _subtitle(CompaniesStateData state) {
    if (state.status == CompaniesStatus.loading) return 'Loading…';
    if (state.status == CompaniesStatus.failure) return 'Could not load';
    final n = state.visible.length;
    final suffix = state.hasMore ? '+' : '';
    return n == 1 ? '1 company' : '$n$suffix companies';
  }

  Widget _body(BuildContext context, CompaniesStateData state) {
    if (state.status == CompaniesStatus.loading) {
      return const LoadingShimmer(itemHeight: 132);
    }

    if (state.status == CompaniesStatus.failure && state.companies.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not reach the server',
        message: state.error,
        action: FilledButton(
          onPressed: () =>
              context.read<CompaniesBloc>().add(const CompaniesRequested()),
          child: const Text('Try again'),
        ),
      );
    }

    if (state.isEmpty) {
      final searching = state.search.trim().isNotEmpty;
      return EmptyState(
        icon: searching ? Icons.search_off : Icons.domain_disabled,
        title: searching
            ? 'Nothing matches "${state.search.trim()}"'
            : 'No companies match these filters',
        message: searching
            ? null
            : state.filter.hiringSoon
                ? 'No company with Flutter evidence has a recent funding or '
                    'expansion signal. Turn off "About to hire" to see the '
                    'full list.'
                : 'Try turning off a filter.',
      );
    }

    final companies = state.visible;
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<CompaniesBloc>().add(const CompaniesRefreshed()),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: companies.length +
            (state.status == CompaniesStatus.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i >= companies.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final company = companies[i];
          return CompanyCard(
            company: company,
            onTap: () => context.push(RoutePaths.companyDetail(company.id)),
          );
        },
      ),
    );
  }
}
