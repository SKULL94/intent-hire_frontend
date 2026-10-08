import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart' as app_errors;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _api;
  final SupabaseClient _supabase;

  ProfileRemoteDataSource(this._api, this._supabase);

  /// Reads the signed-in user's stored profile. Throws `ServerException` with
  /// status 404 when they have not completed onboarding yet.
  Future<UserProfileModel> getProfile() async {
    final data = await _api.get(ApiEndpoints.usersMe);
    if (data is! Map<String, dynamic>) {
      throw const app_errors.ServerException('Unexpected profile response');
    }
    return UserProfileModel.fromJson(data);
  }

  Future<void> saveProfile(UserProfileModel profile) {
    // Backend `upsert_profile` requires `email` on first-time creation of a
    // user row. The Supabase JWT carries it; we forward it here so the backend
    // can seed the row even when the user signed up via phone+OTP.
    final user = _supabase.auth.currentUser;
    final body = {
      ...profile.toJson(),
      if (user?.email != null) 'email': user!.email,
      if (user?.phone != null) 'phone': user!.phone,
    };
    return _api.post(ApiEndpoints.usersProfile, body: body);
  }
}
