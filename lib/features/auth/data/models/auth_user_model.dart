import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const AuthUserModel({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  factory AuthUserModel.fromSupabase(sb.User user) {
    final meta = user.userMetadata ?? const <String, dynamic>{};
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      name: meta['name'] as String? ?? meta['full_name'] as String?,
      avatarUrl: meta['avatar_url'] as String?,
    );
  }

  AuthUser toEntity() => AuthUser(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
}
