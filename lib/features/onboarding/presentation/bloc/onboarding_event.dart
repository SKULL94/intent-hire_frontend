part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => const [];
}

class SkillToggled extends OnboardingEvent {
  final String name;
  const SkillToggled(this.name);

  @override
  List<Object?> get props => [name];
}

class SkillProficiencyChanged extends OnboardingEvent {
  final String name;
  final double proficiency;
  const SkillProficiencyChanged(this.name, this.proficiency);

  @override
  List<Object?> get props => [name, proficiency];
}

class ExperienceYearsChanged extends OnboardingEvent {
  final int years;
  const ExperienceYearsChanged(this.years);

  @override
  List<Object?> get props => [years];
}

class LocationToggled extends OnboardingEvent {
  final String location;
  const LocationToggled(this.location);

  @override
  List<Object?> get props => [location];
}

class MinSalaryChanged extends OnboardingEvent {
  final int? value;
  const MinSalaryChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ProfileSaveRequested extends OnboardingEvent {
  const ProfileSaveRequested();
}
