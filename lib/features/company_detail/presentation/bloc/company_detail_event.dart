part of 'company_detail_bloc.dart';

sealed class CompanyDetailEvent extends Equatable {
  const CompanyDetailEvent();

  @override
  List<Object?> get props => const [];
}

class CompanyDetailRequested extends CompanyDetailEvent {
  final String companyId;
  const CompanyDetailRequested(this.companyId);

  @override
  List<Object?> get props => [companyId];
}
