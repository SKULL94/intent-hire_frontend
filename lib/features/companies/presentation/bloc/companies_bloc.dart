import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/company_filter_store.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_filter.dart';
import '../../domain/usecases/get_companies.dart';

part 'companies_event.dart';
part 'companies_state.dart';

class CompaniesBloc extends Bloc<CompaniesEvent, CompaniesStateData> {
  final GetCompanies _getCompanies;
  final CompanyFilterStore _filterStore;

  CompaniesBloc({
    required GetCompanies getCompanies,
    required CompanyFilterStore filterStore,
  })  : _getCompanies = getCompanies,
        _filterStore = filterStore,
        super(CompaniesStateData(filter: filterStore.read())) {
    on<CompaniesRequested>(_onRequested);
    on<CompaniesRefreshed>(_onRequested);
    on<CompaniesFilterChanged>(_onFilterChanged);
    // A fling fires scroll callbacks far faster than the API answers. The
    // guard inside `_onNextPage` rejects the duplicates, which is enough
    // without pulling in a stream-transformer package.
    on<CompaniesNextPageRequested>(_onNextPage);
    // Search filters the already-loaded page, so it costs nothing and needs
    // no debounce.
    on<CompaniesSearchChanged>(_onSearchChanged);
  }

  Future<void> _onRequested(
    CompaniesEvent event,
    Emitter<CompaniesStateData> emit,
  ) async {
    emit(state.copyWith(status: CompaniesStatus.loading, clearError: true));
    await _load(emit, filter: state.filter, offset: 0, replace: true);
  }

  Future<void> _onFilterChanged(
    CompaniesFilterChanged event,
    Emitter<CompaniesStateData> emit,
  ) async {
    await _filterStore.write(event.filter);
    emit(state.copyWith(
      filter: event.filter,
      status: CompaniesStatus.loading,
      clearError: true,
    ));
    await _load(emit, filter: event.filter, offset: 0, replace: true);
  }

  Future<void> _onNextPage(
    CompaniesNextPageRequested event,
    Emitter<CompaniesStateData> emit,
  ) async {
    if (!state.hasMore || state.status == CompaniesStatus.loadingMore) return;
    emit(state.copyWith(status: CompaniesStatus.loadingMore));
    await _load(
      emit,
      filter: state.filter,
      offset: state.companies.length,
      replace: false,
    );
  }

  void _onSearchChanged(
    CompaniesSearchChanged event,
    Emitter<CompaniesStateData> emit,
  ) {
    emit(state.copyWith(search: event.query));
  }

  Future<void> _load(
    Emitter<CompaniesStateData> emit, {
    required CompanyFilter filter,
    required int offset,
    required bool replace,
  }) async {
    final result = await _getCompanies(GetCompaniesParams(
      filter: filter,
      limit: AppConstants.pageSize,
      offset: offset,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        status: CompaniesStatus.failure,
        error: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: CompaniesStatus.success,
        companies: replace ? page : [...state.companies, ...page],
        hasMore: page.length >= AppConstants.pageSize,
        clearError: true,
      )),
    );
  }
}
