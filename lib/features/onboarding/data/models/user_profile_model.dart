import '../../domain/entities/skill.dart';
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

  /// Parses `GET /api/v1/users/me` (schema: `UserRead`).
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'];
    final skills = <String, double>{};
    if (rawSkills is Map<String, dynamic>) {
      for (final entry in rawSkills.entries) {
        final value = entry.value;
        if (value is num) skills[entry.key] = value.toDouble();
      }
    }
    final locations = json['preferred_locations'];
    return UserProfileModel(
      name: json['name'] as String?,
      skills: skills,
      experienceYears: json['experience_years'] as int? ?? 0,
      preferredLocations: locations is List<dynamic>
          ? locations.whereType<String>().toList()
          : const <String>[],
      minSalary: json['min_salary'] as int?,
    );
  }

  UserProfile toEntity() => UserProfile(
        name: name,
        skills: [
          for (final entry in skills.entries)
            Skill(name: entry.key, proficiency: entry.value.clamp(0.0, 1.0)),
        ],
        experienceYears: experienceYears,
        preferredLocations: preferredLocations,
        minSalary: minSalary,
      );

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
