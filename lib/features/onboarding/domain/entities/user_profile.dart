import 'package:equatable/equatable.dart';

import 'skill.dart';

class UserProfile extends Equatable {
  final String? name;
  final List<Skill> skills;
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

  const UserProfile({
    this.name,
    this.skills = const [],
    this.experienceYears = 0,
    this.preferredLocations = const [],
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

  UserProfile copyWith({
    String? name,
    List<Skill>? skills,
    int? experienceYears,
    List<String>? preferredLocations,
    int? minSalary,
    String? phone,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    String? locationText,
    String? currentEmployer,
    List<String>? highlights,
    String? experienceLabel,
  }) =>
      UserProfile(
        name: name ?? this.name,
        skills: skills ?? this.skills,
        experienceYears: experienceYears ?? this.experienceYears,
        preferredLocations: preferredLocations ?? this.preferredLocations,
        minSalary: minSalary ?? this.minSalary,
        phone: phone ?? this.phone,
        linkedinUrl: linkedinUrl ?? this.linkedinUrl,
        githubUrl: githubUrl ?? this.githubUrl,
        portfolioUrl: portfolioUrl ?? this.portfolioUrl,
        locationText: locationText ?? this.locationText,
        currentEmployer: currentEmployer ?? this.currentEmployer,
        highlights: highlights ?? this.highlights,
        experienceLabel: experienceLabel ?? this.experienceLabel,
      );

  Map<String, double> get skillsMap => {
        for (final s in skills) s.name: s.proficiency,
      };

  @override
  List<Object?> get props => [
        name,
        skills,
        experienceYears,
        preferredLocations,
        minSalary,
        phone,
        linkedinUrl,
        githubUrl,
        portfolioUrl,
        locationText,
        currentEmployer,
        highlights,
        experienceLabel,
      ];
}
