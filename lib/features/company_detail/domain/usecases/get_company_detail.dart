import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/company_detail.dart';
import '../repositories/company_repository.dart';

class GetCompanyDetail implements UseCase<CompanyDetail, String> {
  final CompanyRepository _repo;

  GetCompanyDetail(this._repo);

  @override
  Future<Either<Failure, CompanyDetail>> call(String params) =>
      _repo.getCompanyDetail(params);
}
