import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../onboarding/domain/entities/skill.dart';
import '../bloc/profile_bloc.dart';

/// Edits the stack the match engine scores against. Shares `ProfileBloc` with
/// the profile page, so changes are visible there on pop.
class EditSkillsPage extends StatelessWidget {
  const EditSkillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileStateData>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == ProfileStatus.saved) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Profile saved')),
          );
        } else if (state.status == ProfileStatus.failure &&
            state.errorMessage != null) {
          messenger.showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final selected = {for (final s in state.profile.skills) s.name: s};
        final saving = state.status == ProfileStatus.saving;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit skills')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ExperienceField(
                years: state.profile.experienceYears,
                onChanged: (v) =>
                    context.read<ProfileBloc>().add(ProfileExperienceChanged(v)),
              ),
              const SizedBox(height: 8),
              for (final category in kSkillCatalog) ...[
                const SizedBox(height: 16),
                Text(category.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in category.suggestions)
                      FilterChip(
                        label: Text(name),
                        selected: selected.containsKey(name),
                        onSelected: (_) => context
                            .read<ProfileBloc>()
                            .add(ProfileSkillToggled(name)),
                      ),
                  ],
                ),
                for (final name in category.suggestions)
                  if (selected[name] case final Skill skill)
                    _ProficiencySlider(
                      skill: skill,
                      onChanged: (v) => context
                          .read<ProfileBloc>()
                          .add(ProfileSkillProficiencyChanged(skill.name, v)),
                    ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: saving || state.profile.skills.isEmpty
                    ? null
                    : () => context.read<ProfileBloc>().add(const ProfileSaved()),
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
              if (state.profile.skills.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Pick at least one skill.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ExperienceField extends StatelessWidget {
  final int years;
  final ValueChanged<int> onChanged;

  const _ExperienceField({required this.years, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Years of experience',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        IconButton(
          onPressed: years > 0 ? () => onChanged(years - 1) : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$years', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: years < 50 ? () => onChanged(years + 1) : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _ProficiencySlider extends StatelessWidget {
  final Skill skill;
  final ValueChanged<double> onChanged;

  const _ProficiencySlider({required this.skill, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(skill.name, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Slider(
              value: skill.proficiency.clamp(0.0, 1.0),
              divisions: 10,
              label: '${(skill.proficiency * 100).round()}%',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${(skill.proficiency * 100).round()}%',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
