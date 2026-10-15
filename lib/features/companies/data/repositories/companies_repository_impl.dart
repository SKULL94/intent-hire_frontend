import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/error/failures.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_filter.dart';
import '../../domain/repositories/companies_repository.dart';
import '../datasources/companies_remote_datasource.dart';

class CompaniesRepositoryImpl implements CompaniesRepository {
  final CompaniesRemoteDataSource _remote;

  CompaniesRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Company>>> getCompanies({
    required CompanyFilter filter,
    required int limit,
    required int offset,
  }) =>
      _guard(() => _remote.getCompanies(
            filter: filter,
            limit: limit,
            offset: offset,
          ));

  @override
  Future<Either<Failure, Company>> getCompany(String id) =>
      _guard(() => _remote.getCompany(id));

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } on app_errors.AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on app_errors.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on app_errors.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
