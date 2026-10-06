import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _api;
  final SupabaseClient _supabase;

  ProfileRemoteDataSource(this._api, this._supabase);

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
