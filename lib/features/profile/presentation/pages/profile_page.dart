import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Account and sign-out only.
///
/// There is deliberately no skills profile: the app answers one question about
/// Flutter, so there is nothing to personalise. Auth exists to gate the API,
/// not to tailor the list.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final identity = context.select<AuthBloc, String?>((b) {
      final user = b.state.user;
      final email = user?.email;
      if (email != null && email.isNotEmpty) return email;
      return null;
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      child: Text(
                        (identity?.isNotEmpty ?? false)
                            ? identity![0].toUpperCase()
                            : '?',
                        style: text.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            identity ?? 'Signed in',
                            style: text.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Flutter · Delhi NCR or remote',
                            style: text.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('About', style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              'This app tracks which companies build in Flutter and which are '
              'about to hire — not which have a vacancy open today. Evidence '
              'comes from what companies ship and post, and a verified badge '
              'means the proof came from a shipped artefact rather than the '
              'wording of a job description.',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            const _InfoRow(label: 'API', value: AppConstants.apiBaseUrl),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () =>
                  context.read<AuthBloc>().add(const SignOutRequested()),
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: text.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
