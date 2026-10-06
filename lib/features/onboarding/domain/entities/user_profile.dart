import 'package:equatable/equatable.dart';

import 'skill.dart';

class UserProfile extends Equatable {
  final String? name;
  final List<Skill> skills;
  final int experienceYears;
  final List<String> preferredLocations;
  final int? minSalary;

  const UserProfile({
    this.name,
    this.skills = const [],
    this.experienceYears = 0,
    this.preferredLocations = const [],
    this.minSalary,
  });

  UserProfile copyWith({
    String? name,
    List<Skill>? skills,
    int? experienceYears,
    List<String>? preferredLocations,
    int? minSalary,
  }) =>
      UserProfile(
        name: name ?? this.name,
        skills: skills ?? this.skills,
        experienceYears: experienceYears ?? this.experienceYears,
        preferredLocations: preferredLocations ?? this.preferredLocations,
        minSalary: minSalary ?? this.minSalary,
      );

  Map<String, double> get skillsMap => {
        for (final s in skills) s.name: s.proficiency,
      };

  @override
  List<Object?> get props =>
      [name, skills, experienceYears, preferredLocations, minSalary];
}
