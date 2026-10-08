import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/company_detail.dart';

abstract class CompanyRepository {
  Future<Either<Failure, CompanyDetail>> getCompanyDetail(String companyId);
}
