import 'package:equatable/equatable.dart';

class Skill extends Equatable {
  final String name;
  final double proficiency;

  const Skill({required this.name, required this.proficiency})
      : assert(proficiency >= 0 && proficiency <= 1);

  Skill copyWith({String? name, double? proficiency}) =>
      Skill(name: name ?? this.name, proficiency: proficiency ?? this.proficiency);

  @override
  List<Object?> get props => [name, proficiency];
}

class SkillCategory extends Equatable {
  final String name;
  final List<String> suggestions;

  const SkillCategory({required this.name, required this.suggestions});

  @override
  List<Object?> get props => [name, suggestions];
}

const List<SkillCategory> kSkillCatalog = [
  SkillCategory(
    name: 'Mobile',
    suggestions: ['flutter', 'dart', 'kotlin', 'swift', 'react-native'],
  ),
  SkillCategory(
    name: 'Backend',
    suggestions: ['python', 'fastapi', 'django', 'nodejs', 'go', 'rust', 'java'],
  ),
  SkillCategory(
    name: 'Database',
    suggestions: ['postgresql', 'mysql', 'mongodb', 'redis', 'supabase', 'firebase'],
  ),
  SkillCategory(
    name: 'Cloud & DevOps',
    suggestions: ['aws', 'gcp', 'azure', 'docker', 'kubernetes', 'terraform'],
  ),
];
