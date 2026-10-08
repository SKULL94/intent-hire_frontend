import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../../../core/widgets/tech_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
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
