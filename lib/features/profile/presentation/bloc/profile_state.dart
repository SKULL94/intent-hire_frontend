part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, loaded, saving, saved, failure }

class ProfileStateData extends Equatable {
  final UserProfile profile;
  final ProfileStatus status;
  final String? errorMessage;

  const ProfileStateData({
    required this.profile,
    this.status = ProfileStatus.initial,
    this.errorMessage,
  });

  const ProfileStateData.initial()
      : profile = const UserProfile(),
        status = ProfileStatus.initial,
        errorMessage = null;

  ProfileStateData copyWith({
    UserProfile? profile,
    ProfileStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) =>
      ProfileStateData(
        profile: profile ?? this.profile,
        status: status ?? this.status,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  /// Lowercased skill names, which is what the matches list compares against a
  /// company's stack fingerprint.
  Set<String> get skillNames =>
      profile.skills.map((s) => s.name.toLowerCase()).toSet();

  @override
  List<Object?> get props => [profile, status, errorMessage];
}
