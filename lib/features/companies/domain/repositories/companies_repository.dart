import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/company.dart';
import '../entities/company_filter.dart';

abstract class CompaniesRepository {
  Future<Either<Failure, List<Company>>> getCompanies({
    required CompanyFilter filter,
    required int limit,
    required int offset,
  });

  Future<Either<Failure, Company>> getCompany(String id);
}
