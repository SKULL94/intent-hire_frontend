import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_paths.dart';
import '../../domain/entities/skill.dart';
import '../bloc/onboarding_bloc.dart';

const List<String> _kLocationOptions = [
  'Remote',
  'Bangalore',
  'Hyderabad',
  'Mumbai',
  'Delhi NCR',
  'Pune',
  'Chennai',
];

class SkillSetupPage extends StatelessWidget {
  const SkillSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingStateData>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          context.go(RoutePaths.matches);
        } else if (state.status == OnboardingStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final selected = {for (final s in state.profile.skills) s.name: s};
        return Scaffold(
          appBar: AppBar(title: const Text('Your tech stack')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Pick what you work with. Set a proficiency for each.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final cat in kSkillCatalog)
                  _CategorySection(
                    category: cat,
                    selected: selected,
                  ),
                const SizedBox(height: 24),
                _SectionLabel(context, 'Preferred locations'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final loc in _kLocationOptions)
                      FilterChip(
                        label: Text(loc),
                        selected:
                            state.profile.preferredLocations.contains(loc),
                        onSelected: (_) => context
                            .read<OnboardingBloc>()
                            .add(LocationToggled(loc)),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel(context, 'Experience: ${state.profile.experienceYears} yrs'),
                Slider(
                  value: state.profile.experienceYears.toDouble(),
                  min: 0,
                  max: 20,
                  divisions: 20,
                  label: '${state.profile.experienceYears}',
                  onChanged: (v) => context
                      .read<OnboardingBloc>()
                      .add(ExperienceYearsChanged(v.round())),
                ),
                const SizedBox(height: 16),
                _SectionLabel(context, 'Minimum monthly salary (₹)'),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Optional',
                    prefixText: '₹ ',
                  ),
                  onChanged: (v) {
                    final value = int.tryParse(v.trim());
                    context.read<OnboardingBloc>().add(MinSalaryChanged(value));
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.status == OnboardingStatus.submitting
                      ? null
                      : () => context
                          .read<OnboardingBloc>()
                          .add(const ProfileSaveRequested()),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: state.status == OnboardingStatus.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save and find matches'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final SkillCategory category;
  final Map<String, Skill> selected;

  const _CategorySection({required this.category, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(category.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final name in category.suggestions)
          _SkillRow(name: name, skill: selected[name]),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  final String name;
  final Skill? skill;
  const _SkillRow({required this.name, required this.skill});

  @override
  Widget build(BuildContext context) {
    final isSelected = skill != null;
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Checkbox(
            value: isSelected,
            onChanged: (_) =>
                context.read<OnboardingBloc>().add(SkillToggled(name)),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(name, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Expanded(
          flex: 5,
          child: Slider(
            value: skill?.proficiency ?? 0,
            onChanged: isSelected
                ? (v) => context
                    .read<OnboardingBloc>()
                    .add(SkillProficiencyChanged(name, v))
                : null,
          ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            isSelected ? '${((skill!.proficiency) * 100).round()}%' : '—',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables, use_super_parameters
  _SectionLabel(this.context, this.text);
  final BuildContext context;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}
