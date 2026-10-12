part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}

class ProfileSkillToggled extends ProfileEvent {
  final String name;
  const ProfileSkillToggled(this.name);

  @override
  List<Object?> get props => [name];
}

class ProfileSkillProficiencyChanged extends ProfileEvent {
  final String name;
  final double proficiency;
  const ProfileSkillProficiencyChanged(this.name, this.proficiency);

  @override
  List<Object?> get props => [name, proficiency];
}

class ProfileExperienceChanged extends ProfileEvent {
  final int years;
  const ProfileExperienceChanged(this.years);

  @override
  List<Object?> get props => [years];
}

class ProfileSaved extends ProfileEvent {
  const ProfileSaved();
}

class ProfileBioChanged extends ProfileEvent {
  final String? phone;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? locationText;
  final String? currentEmployer;
  final List<String> highlights;
  final String? experienceLabel;

  const ProfileBioChanged({
    this.phone,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.locationText,
    this.currentEmployer,
    this.highlights = const [],
    this.experienceLabel,
  });

  @override
  List<Object?> get props => [
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
