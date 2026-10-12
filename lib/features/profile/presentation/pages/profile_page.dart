import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/tech_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileStateData>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = state.profile;
          // AuthUser carries only `email`; a phone-OTP account leaves it blank.
          final authUser = context.select<AuthBloc, String?>((b) {
            final email = b.state.user?.email;
            return (email == null || email.isEmpty) ? null : email;
          });

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ProfileBloc>().add(const ProfileRequested()),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(
                            (profile.name?.isNotEmpty ?? false)
                                ? profile.name![0].toUpperCase()
                                : '?',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name ?? 'Unnamed',
                                style: theme.textTheme.titleMedium,
                              ),
                              if (authUser != null)
                                Text(
                                  authUser,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${profile.experienceYears} yrs experience',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your stack', style: theme.textTheme.titleMedium),
                    TextButton.icon(
                      onPressed: () => context.push(RoutePaths.editSkills),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (profile.skills.isEmpty)
                  Text(
                    'No skills yet — add some so we can match you.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final skill in profile.skills)
                        TechChip(
                          tech: skill.name,
                          confidence: skill.proficiency,
                          matched: true,
                        ),
                    ],
                  ),
                if (profile.preferredLocations.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Preferred locations', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final location in profile.preferredLocations)
                        TechChip(tech: location),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                _BioCard(profile: profile),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  final UserProfile profile;

  const _BioCard({required this.profile});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final employer = profile.currentEmployer;
    final location = profile.locationText;
    final linkedin = profile.linkedinUrl;
    final github = profile.githubUrl;
    final portfolio = profile.portfolioUrl;
    final hasLinks = linkedin != null || github != null || portfolio != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bio & contacts', style: theme.textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => context.push(RoutePaths.editBio),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ],
            ),
            if (employer != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.business_outlined, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      employer,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (location != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.place_outlined, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      location,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            if (hasLinks) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (linkedin != null)
                    ActionChip(
                      avatar: const Icon(Icons.link, size: 14),
                      label: const Text('LinkedIn'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _launch(context, linkedin),
                    ),
                  if (github != null)
                    ActionChip(
                      avatar: const Icon(Icons.code, size: 14),
                      label: const Text('GitHub'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _launch(context, github),
                    ),
                  if (portfolio != null)
                    ActionChip(
                      avatar: const Icon(Icons.web_outlined, size: 14),
                      label: const Text('Portfolio'),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _launch(context, portfolio),
                    ),
                ],
              ),
            ],
            if (employer == null && location == null && !hasLinks)
              Text(
                'Add your bio to personalise cold emails.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
