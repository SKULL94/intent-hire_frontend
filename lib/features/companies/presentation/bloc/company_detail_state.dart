part of 'company_detail_bloc.dart';

enum CompanyDetailStatus { initial, loading, success, failure }

class CompanyDetailStateData extends Equatable {
  final CompanyDetailStatus status;
  final Company? company;
  final String? error;

  const CompanyDetailStateData({
    this.status = CompanyDetailStatus.initial,
    this.company,
    this.error,
  });

  CompanyDetailStateData copyWith({
    CompanyDetailStatus? status,
    Company? company,
    String? error,
  }) =>
      CompanyDetailStateData(
        status: status ?? this.status,
        company: company ?? this.company,
        error: error,
      );

  @override
  List<Object?> get props => [status, company, error];
}
