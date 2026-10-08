import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/company_detail.dart';
import '../models/company_detail_model.dart';

class CompanyRemoteDataSource {
  final ApiClient _api;

  CompanyRemoteDataSource(this._api);

  Future<CompanyDetail> getCompanyDetail(String companyId) async {
    final data = await _api.get(ApiEndpoints.companyById(companyId));
    if (data is! Map<String, dynamic>) {
      throw const app_errors.ServerException('Unexpected company response');
    }
    return CompanyDetailModel.fromJson(data);
  }
}
