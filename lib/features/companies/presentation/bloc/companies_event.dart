part of 'companies_bloc.dart';

sealed class CompaniesEvent extends Equatable {
  const CompaniesEvent();

  @override
  List<Object?> get props => const [];
}

/// First load. Reads the persisted filter before fetching.
class CompaniesRequested extends CompaniesEvent {
  const CompaniesRequested();
}

/// Pull to refresh: same filter, back to the first page.
class CompaniesRefreshed extends CompaniesEvent {
  const CompaniesRefreshed();
}

class CompaniesNextPageRequested extends CompaniesEvent {
  const CompaniesNextPageRequested();
}

class CompaniesFilterChanged extends CompaniesEvent {
  final CompanyFilter filter;
  const CompaniesFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

/// Free-text narrowing, applied on the loaded page rather than the server —
/// the API has no search parameter and the result set is small.
class CompaniesSearchChanged extends CompaniesEvent {
  final String query;
  const CompaniesSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
