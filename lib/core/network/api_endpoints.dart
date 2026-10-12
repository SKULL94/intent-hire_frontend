class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String usersProfile = '/api/v1/users/profile';
  static const String usersMe = '/api/v1/users/me';

  static const String companies = '/api/v1/companies';
  static String companyById(String id) => '/api/v1/companies/$id';
  static String companySignals(String id) => '/api/v1/companies/$id/signals';
  static String companyRecruiterEmail(String id) => '/api/v1/companies/$id/recruiter-email';

  // Job-level search. Unlike /matches this is not per-user: it filters
  // postings directly, which is the only way to ask about one technology in
  // one city.
  static const String jobs = '/api/v1/jobs';
  static const String jobFacets = '/api/v1/jobs/facets';

  static const String matches = '/api/v1/matches';
  static const String matchesRefresh = '/api/v1/matches/refresh';
  // PATCH only — backend has no GET for a single match.
  static String patchMatchById(String id) => '/api/v1/matches/$id';

  static String jobComposeEmail(String id) => '/api/v1/jobs/$id/compose-email';
  static String companyComposeEmail(String id) =>
      '/api/v1/companies/$id/compose-email';
}
