import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/skill.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/save_profile.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingStateData> {
  final SaveProfile _saveProfile;

  OnboardingBloc({required SaveProfile saveProfile})
      : _saveProfile = saveProfile,
        super(const OnboardingStateData.initial()) {
    on<SkillToggled>(_onToggle);
    on<SkillProficiencyChanged>(_onProficiency);
    on<ExperienceYearsChanged>(_onYears);
    on<LocationToggled>(_onLocation);
    on<MinSalaryChanged>(_onSalary);
    on<ProfileSaveRequested>(_onSave);
  }

  void _onToggle(SkillToggled e, Emitter<OnboardingStateData> emit) {
    final current = [...state.profile.skills];
    final existing = current.indexWhere((s) => s.name == e.name);
    if (existing >= 0) {
      current.removeAt(existing);
    } else {
      current.add(Skill(name: e.name, proficiency: 0.5));
    }
    emit(state.copyWith(profile: state.profile.copyWith(skills: current)));
  }

  void _onProficiency(
    SkillProficiencyChanged e,
    Emitter<OnboardingStateData> emit,
  ) {
    final updated = state.profile.skills
        .map((s) => s.name == e.name
            ? s.copyWith(proficiency: e.proficiency)
            : s)
        .toList();
    emit(state.copyWith(profile: state.profile.copyWith(skills: updated)));
  }

  void _onYears(ExperienceYearsChanged e, Emitter<OnboardingStateData> emit) {
    emit(state.copyWith(
      profile: state.profile.copyWith(experienceYears: e.years),
    ));
  }

  void _onLocation(LocationToggled e, Emitter<OnboardingStateData> emit) {
    final current = [...state.profile.preferredLocations];
    if (current.contains(e.location)) {
      current.remove(e.location);
    } else {
      current.add(e.location);
    }
    emit(state.copyWith(
      profile: state.profile.copyWith(preferredLocations: current),
    ));
  }

  void _onSalary(MinSalaryChanged e, Emitter<OnboardingStateData> emit) {
    emit(state.copyWith(
      profile: state.profile.copyWith(minSalary: e.value),
    ));
  }

  Future<void> _onSave(
    ProfileSaveRequested e,
    Emitter<OnboardingStateData> emit,
  ) async {
    if (!state.canSubmit) {
      emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: 'Select at least one skill',
      ));
      return;
    }
    emit(state.copyWith(status: OnboardingStatus.submitting, clearError: true));
    final res = await _saveProfile(state.profile);
    res.fold(
      (f) => emit(state.copyWith(
        status: OnboardingStatus.failure,
        errorMessage: f.message,
      )),
      (_) => emit(state.copyWith(status: OnboardingStatus.success)),
    );
  }
}
