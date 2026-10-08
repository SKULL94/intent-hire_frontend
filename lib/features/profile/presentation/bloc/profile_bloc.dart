import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../onboarding/domain/entities/skill.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/domain/usecases/get_profile.dart';
import '../../../onboarding/domain/usecases/save_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Owns the signed-in user's profile for the whole authenticated shell.
///
/// Provided above the bottom-nav shell rather than per-page, because the
/// matches list also needs the user's skills in order to highlight which
/// technologies a company has in common with them.
class ProfileBloc extends Bloc<ProfileEvent, ProfileStateData> {
  final GetProfile _getProfile;
  final SaveProfile _saveProfile;

  ProfileBloc({
    required GetProfile getProfile,
    required SaveProfile saveProfile,
  })  : _getProfile = getProfile,
        _saveProfile = saveProfile,
        super(const ProfileStateData.initial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileSkillToggled>(_onSkillToggled);
    on<ProfileSkillProficiencyChanged>(_onProficiency);
    on<ProfileExperienceChanged>(_onExperience);
    on<ProfileSaved>(_onSaved);
  }

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileStateData> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    final result = await _getProfile(const NoParams());
    result.fold(
      (f) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: f.message,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
        clearError: true,
      )),
    );
  }

  void _onSkillToggled(
    ProfileSkillToggled event,
    Emitter<ProfileStateData> emit,
  ) {
    final skills = [...state.profile.skills];
    final index = skills.indexWhere((s) => s.name == event.name);
    if (index >= 0) {
      skills.removeAt(index);
    } else {
      skills.add(Skill(name: event.name, proficiency: 0.5));
    }
    emit(state.copyWith(profile: state.profile.copyWith(skills: skills)));
  }

  void _onProficiency(
    ProfileSkillProficiencyChanged event,
    Emitter<ProfileStateData> emit,
  ) {
    final skills = state.profile.skills
        .map((s) =>
            s.name == event.name ? s.copyWith(proficiency: event.proficiency) : s)
        .toList();
    emit(state.copyWith(profile: state.profile.copyWith(skills: skills)));
  }

  void _onExperience(
    ProfileExperienceChanged event,
    Emitter<ProfileStateData> emit,
  ) {
    emit(state.copyWith(
      profile: state.profile.copyWith(experienceYears: event.years),
    ));
  }

  Future<void> _onSaved(ProfileSaved event, Emitter<ProfileStateData> emit) async {
    emit(state.copyWith(status: ProfileStatus.saving, clearError: true));
    final result = await _saveProfile(state.profile);
    result.fold(
      (f) => emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(status: ProfileStatus.saved, clearError: true)),
    );
  }
}
