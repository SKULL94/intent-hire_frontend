import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/company.dart';
import '../../domain/usecases/get_company.dart';

part 'company_detail_event.dart';
part 'company_detail_state.dart';

class CompanyDetailBloc
    extends Bloc<CompanyDetailEvent, CompanyDetailStateData> {
  final GetCompany _getCompany;

  CompanyDetailBloc({required GetCompany getCompany})
      : _getCompany = getCompany,
        super(const CompanyDetailStateData()) {
    on<CompanyDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    CompanyDetailRequested event,
    Emitter<CompanyDetailStateData> emit,
  ) async {
    emit(state.copyWith(status: CompanyDetailStatus.loading));
    final result = await _getCompany(event.companyId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CompanyDetailStatus.failure,
        error: failure.message,
      )),
      (company) => emit(state.copyWith(
        status: CompanyDetailStatus.success,
        company: company,
      )),
    );
  }
}
