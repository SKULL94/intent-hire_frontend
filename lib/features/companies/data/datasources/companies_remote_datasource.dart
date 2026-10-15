import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/company.dart';
import '../../domain/entities/company_filter.dart';
import '../models/company_model.dart';

class CompaniesRemoteDataSource {
  final ApiClient _api;

  CompaniesRemoteDataSource(this._api);

  Future<List<Company>> getCompanies({
    required CompanyFilter filter,
    required int limit,
    required int offset,
  }) async {
    final data = await _api.get(
      ApiEndpoints.companies,
      query: filter.toQuery(limit: limit, offset: offset),
    );
    if (data is! List) {
      throw const app_errors.ServerException('Unexpected companies response');
    }
    return CompanyModel.listFromJson(data);
  }

  Future<Company> getCompany(String id) async {
    final data = await _api.get(ApiEndpoints.companyById(id));
    if (data is! Map<String, dynamic>) {
      throw const app_errors.ServerException('Unexpected company response');
    }
    return CompanyModel.fromJson(data);
  }
}
