// ignore_for_file: deprecated_member_use
// Supabase SDK renames `anonKey` → `publishableKey` in a future major; pin here.

import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

Future<void> initSupabase() async {
  if (AppConstants.supabaseUrl.isEmpty || AppConstants.supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY not set. Pass them via --dart-define.',
    );
  }
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
}
