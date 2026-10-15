import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/company.dart';
import '../repositories/companies_repository.dart';

class GetCompany implements UseCase<Company, String> {
  final CompaniesRepository _repo;

  GetCompany(this._repo);

  @override
  Future<Either<Failure, Company>> call(String params) =>
      _repo.getCompany(params);
}
