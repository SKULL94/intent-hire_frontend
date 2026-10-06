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

  static const double highScoreThreshold = 70.0;
  static const double medScoreThreshold = 40.0;

  static const int matchesPageSize = 20;

  static const Duration httpTimeout = Duration(seconds: 20);
}
