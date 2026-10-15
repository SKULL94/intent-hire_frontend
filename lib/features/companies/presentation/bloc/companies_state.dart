part of 'companies_bloc.dart';

enum CompaniesStatus { initial, loading, loadingMore, success, failure }

class CompaniesStateData extends Equatable {
  final CompaniesStatus status;
  final List<Company> companies;
  final CompanyFilter filter;
  final String search;
  final String? error;
  final bool hasMore;

  const CompaniesStateData({
    this.status = CompaniesStatus.initial,
    this.companies = const [],
    this.filter = CompanyFilter.initial,
    this.search = '',
    this.error,
    this.hasMore = true,
  });

  /// Search is applied here rather than in the widget so the count shown in
  /// the header and the list body can never disagree.
  List<Company> get visible {
    final needle = search.trim().toLowerCase();
    if (needle.isEmpty) return companies;
    return companies.where((c) {
      if (c.name.toLowerCase().contains(needle)) return true;
      if (c.domain?.toLowerCase().contains(needle) ?? false) return true;
      if (c.location?.toLowerCase().contains(needle) ?? false) return true;
      return false;
    }).toList();
  }

  bool get isEmpty =>
      status == CompaniesStatus.success && visible.isEmpty;

  CompaniesStateData copyWith({
    CompaniesStatus? status,
    List<Company>? companies,
    CompanyFilter? filter,
    String? search,
    String? error,
    bool? hasMore,
    bool clearError = false,
  }) =>
      CompaniesStateData(
        status: status ?? this.status,
        companies: companies ?? this.companies,
        filter: filter ?? this.filter,
        search: search ?? this.search,
        error: clearError ? null : (error ?? this.error),
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  List<Object?> get props =>
      [status, companies, filter, search, error, hasMore];
}
