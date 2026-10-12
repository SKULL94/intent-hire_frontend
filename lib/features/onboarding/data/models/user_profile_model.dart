import '../../domain/entities/skill.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  final String? name;
  final Map<String, double> skills;
  final int experienceYears;
  final List<String> preferredLocations;
  final int? minSalary;
  final String? phone;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? locationText;
  final String? currentEmployer;
  final List<String> highlights;
  final String? experienceLabel;

  const UserProfileModel({
    this.name,
    required this.skills,
    required this.experienceYears,
    required this.preferredLocations,
    this.minSalary,
    this.phone,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.locationText,
    this.currentEmployer,
    this.highlights = const [],
    this.experienceLabel,
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
    final rawHighlights = json['highlights'];
    return UserProfileModel(
      name: json['name'] as String?,
      skills: skills,
      experienceYears: json['experience_years'] as int? ?? 0,
      preferredLocations: locations is List<dynamic>
          ? locations.whereType<String>().toList()
          : const <String>[],
      minSalary: json['min_salary'] as int?,
      phone: json['phone'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      githubUrl: json['github_url'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      locationText: json['location_text'] as String?,
      currentEmployer: json['current_employer'] as String?,
      highlights: rawHighlights is List<dynamic>
          ? rawHighlights.whereType<String>().toList()
          : const <String>[],
      experienceLabel: json['experience_label'] as String?,
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
        phone: phone,
        linkedinUrl: linkedinUrl,
        githubUrl: githubUrl,
        portfolioUrl: portfolioUrl,
        locationText: locationText,
        currentEmployer: currentEmployer,
        highlights: highlights,
        experienceLabel: experienceLabel,
      );

  factory UserProfileModel.fromEntity(UserProfile p) => UserProfileModel(
        name: p.name,
        skills: p.skillsMap,
        experienceYears: p.experienceYears,
        preferredLocations: p.preferredLocations,
        minSalary: p.minSalary,
        phone: p.phone,
        linkedinUrl: p.linkedinUrl,
        githubUrl: p.githubUrl,
        portfolioUrl: p.portfolioUrl,
        locationText: p.locationText,
        currentEmployer: p.currentEmployer,
        highlights: p.highlights,
        experienceLabel: p.experienceLabel,
      );

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        'skills': skills,
        'experience_years': experienceYears,
        'preferred_locations': preferredLocations,
        if (minSalary != null) 'min_salary': minSalary,
        if (phone != null) 'phone': phone,
        if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
        if (githubUrl != null) 'github_url': githubUrl,
        if (portfolioUrl != null) 'portfolio_url': portfolioUrl,
        if (locationText != null) 'location_text': locationText,
        if (currentEmployer != null) 'current_employer': currentEmployer,
        if (highlights.isNotEmpty) 'highlights': highlights,
        if (experienceLabel != null) 'experience_label': experienceLabel,
      };
}
