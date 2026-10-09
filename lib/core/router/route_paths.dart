class RoutePaths {
  const RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String skillSetup = '/onboarding/skills';

  static const String matches = '/matches';
  static const String jobs = '/jobs';
  static const String profile = '/profile';
  static const String editSkills = '/profile/edit-skills';

  static const String company = '/company';
  static String companyDetail(String id) => '/company/$id';
}
