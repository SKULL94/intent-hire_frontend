import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/company_detail.dart';
import '../../domain/usecases/get_company_detail.dart';

part 'company_detail_event.dart';
part 'company_detail_state.dart';

class CompanyDetailBloc
    extends Bloc<CompanyDetailEvent, CompanyDetailStateData> {
  final GetCompanyDetail _getCompanyDetail;

  CompanyDetailBloc({required GetCompanyDetail getCompanyDetail})
      : _getCompanyDetail = getCompanyDetail,
        super(const CompanyDetailStateData.initial()) {
    on<CompanyDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CompanyDetailRequested event,
    Emitter<CompanyDetailStateData> emit,
  ) async {
    emit(state.copyWith(
      status: CompanyDetailStatus.loading,
      clearError: true,
    ));
    final result = await _getCompanyDetail(event.companyId);
    result.fold(
      (f) => emit(state.copyWith(
        status: CompanyDetailStatus.failure,
        errorMessage: f.message,
      )),
      (detail) => emit(state.copyWith(
        status: CompanyDetailStatus.loaded,
        company: detail,
        clearError: true,
      )),
    );
  }
}
