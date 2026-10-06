class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String usersProfile = '/api/v1/users/profile';

  static const String companies = '/api/v1/companies';
  static String companyById(String id) => '/api/v1/companies/$id';
  static String companySignals(String id) => '/api/v1/companies/$id/signals';

  static const String matches = '/api/v1/matches';
  static const String matchesRefresh = '/api/v1/matches/refresh';
  // PATCH only — backend has no GET for a single match.
  static String patchMatchById(String id) => '/api/v1/matches/$id';
}
