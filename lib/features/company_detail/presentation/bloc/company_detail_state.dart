part of 'company_detail_bloc.dart';

enum CompanyDetailStatus { initial, loading, loaded, failure }

class CompanyDetailStateData extends Equatable {
  final CompanyDetail? company;
  final CompanyDetailStatus status;
  final String? errorMessage;

  const CompanyDetailStateData({
    this.company,
    this.status = CompanyDetailStatus.initial,
    this.errorMessage,
  });

  const CompanyDetailStateData.initial()
      : company = null,
        status = CompanyDetailStatus.initial,
        errorMessage = null;

  CompanyDetailStateData copyWith({
    CompanyDetail? company,
    CompanyDetailStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      CompanyDetailStateData(
        company: company ?? this.company,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [company, status, errorMessage];
}
