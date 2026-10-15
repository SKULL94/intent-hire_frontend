import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/company.dart';
import '../entities/company_filter.dart';
import '../repositories/companies_repository.dart';

class GetCompaniesParams extends Equatable {
  final CompanyFilter filter;
  final int limit;
  final int offset;

  const GetCompaniesParams({
    required this.filter,
    required this.limit,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [filter, limit, offset];
}

class GetCompanies implements UseCase<List<Company>, GetCompaniesParams> {
  final CompaniesRepository _repo;

  GetCompanies(this._repo);

  @override
  Future<Either<Failure, List<Company>>> call(GetCompaniesParams params) =>
      _repo.getCompanies(
        filter: params.filter,
        limit: params.limit,
        offset: params.offset,
      );
}
