part of 'onboarding_bloc.dart';

enum OnboardingStatus { editing, submitting, success, failure }

class OnboardingStateData extends Equatable {
  final UserProfile profile;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingStateData({
    required this.profile,
    this.status = OnboardingStatus.editing,
    this.errorMessage,
  });

  const OnboardingStateData.initial()
      : profile = const UserProfile(),
        status = OnboardingStatus.editing,
        errorMessage = null;

  OnboardingStateData copyWith({
    UserProfile? profile,
    OnboardingStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      OnboardingStateData(
        profile: profile ?? this.profile,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  bool get canSubmit => profile.skills.isNotEmpty;

  @override
  List<Object?> get props => [profile, status, errorMessage];
}
