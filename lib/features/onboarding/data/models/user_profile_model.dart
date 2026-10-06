import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String? name;
  final Map<String, double> skills;
  final int experienceYears;
  final List<String> preferredLocations;
  final int? minSalary;

  const UserProfileModel({
    this.name,
    required this.skills,
    required this.experienceYears,
    required this.preferredLocations,
    this.minSalary,
  });

  factory UserProfileModel.fromEntity(UserProfile p) => UserProfileModel(
        name: p.name,
        skills: p.skillsMap,
        experienceYears: p.experienceYears,
        preferredLocations: p.preferredLocations,
        minSalary: p.minSalary,
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        'skills': skills,
        'experience_years': experienceYears,
        'preferred_locations': preferredLocations,
        if (minSalary != null) 'min_salary': minSalary,
      };
}
