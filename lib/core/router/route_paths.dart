class RoutePaths {
  const RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';

  /// The home tab and the app's only list.
  static const String companies = '/companies';
  static const String profile = '/profile';

  static const String company = '/company';
  static String companyDetail(String id) => '/company/$id';
}
