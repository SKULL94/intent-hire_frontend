class AppConstants {
  const AppConstants._();

  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String oauthRedirect = 'io.hiresignal.app://callback';

  /// Companies per page. The whole registry is a few hundred rows, so this is
  /// about scroll smoothness rather than protecting the server.
  static const int pageSize = 30;

  static const Duration httpTimeout = Duration(seconds: 20);
}
