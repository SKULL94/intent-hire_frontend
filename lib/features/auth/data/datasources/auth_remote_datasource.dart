import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart' as app_errors;
import '../models/auth_user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSource(this._supabase);

  Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const app_errors.AuthException('Sign-in failed');
      }
      return AuthUserModel.fromSupabase(user);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<AuthUserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name == null ? null : {'name': name},
      );
      final user = res.user;
      if (user == null) {
        throw const app_errors.AuthException('Sign-up failed');
      }
      return AuthUserModel.fromSupabase(user);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConstants.oauthRedirect,
      );
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<void> sendPhoneOtp({required String phone}) async {
    try {
      await _supabase.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<AuthUserModel> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final res = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      final user = res.user;
      if (user == null) {
        throw const app_errors.AuthException('OTP verification failed');
      }
      return AuthUserModel.fromSupabase(user);
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw app_errors.AuthException(e.message);
    }
  }

  Stream<AuthUserModel?> watchAuthState() => _supabase.auth.onAuthStateChange
      .map((change) {
        final user = change.session?.user;
        return user == null ? null : AuthUserModel.fromSupabase(user);
      });

  AuthUserModel? currentUser() {
    final user = _supabase.auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabase(user);
  }
}
