class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  /// The product. Query parameters are the three switches:
  /// `flutter_only`, `ncr_or_remote`, `hiring_soon`, plus `limit`/`offset`.
  static const String companies = '/api/v1/companies';

  /// Same row, plus the evidence (`stack_signals`) and hiring signals
  /// (`intent_signals`) behind it.
  static String companyById(String id) => '/api/v1/companies/$id';

  static const String usersMe = '/api/v1/users/me';
}
