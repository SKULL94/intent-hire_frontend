import 'package:flutter/material.dart';

import '../../../onboarding/domain/entities/skill.dart';
import '../../domain/entities/job.dart';
import '../../domain/repositories/jobs_repository.dart';

/// Filter sheet for job search: technology, location, and experience ceiling.
/// Returns the new filter, or null if dismissed.
class JobFilterSheet extends StatefulWidget {
  final JobFilter initial;

  /// Technologies present in the loaded results, so the sheet offers what the
  /// data can actually satisfy rather than a fixed list.
  final List<String> availableTechnologies;

  const JobFilterSheet({
    super.key,
    required this.initial,
    this.availableTechnologies = const [],
  });

  static Future<JobFilter?> show(
    BuildContext context,
    JobFilter initial, {
    List<String> availableTechnologies = const [],
  }) =>
      showModalBottomSheet<JobFilter>(
        context: context,
        isScrollControlled: true,
        builder: (_) => JobFilterSheet(
          initial: initial,
          availableTechnologies: availableTechnologies,
        ),
      );

  @override
  State<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends State<JobFilterSheet> {
  // Mutated in place by the chips, so the set itself never gets reassigned.
  late final Set<String> _technologies = {...widget.initial.technologies};
  late final Set<String> _locations = {...widget.initial.locations};
  late bool _includeRemote = widget.initial.includeRemote;
  late int? _maxYears = widget.initial.maxYearsExperience;

  /// The catalog the user already picks their own skills from, plus anything
  /// present in the current results, plus whatever they have already selected
  /// (so an active filter never silently disappears from the sheet).
  List<String> get _technologyOptions {
    final catalog = [
      for (final category in kSkillCatalog) ...category.suggestions,
    ];
    return <String>{
      ...widget.initial.technologies,
      ...widget.availableTechnologies,
      ...catalog,
    }.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                children: [
                  Text('Filter jobs', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 20),

                  _SectionLabel(
                    'Technology',
                    hint: _technologies.isEmpty
                        ? 'All technologies'
                        : 'Matches any selected',
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tech in _technologyOptions)
                        FilterChip(
                          label: Text(tech),
                          selected: _technologies.contains(tech),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _technologies.add(tech);
                            } else {
                              _technologies.remove(tech);
                            }
                          }),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const _SectionLabel('Location'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key in JobLocations.all)
                        FilterChip(
                          label: Text(JobLocations.label(key)),
                          selected: _locations.contains(key),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _locations.add(key);
                            } else {
                              _locations.remove(key);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Include remote roles'),
                    // Remote is additive, not a city: with a city selected the
                    // backend returns that city OR remote.
                    subtitle: Text(
                      _locations.isEmpty
                          ? 'Show remote roles anywhere'
                          : 'Show remote roles as well as the cities above',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _includeRemote,
                    onChanged: (v) => setState(() => _includeRemote = v),
                  ),

                  const SizedBox(height: 16),
                  _SectionLabel(
                    'Experience',
                    hint: _maxYears == null
                        ? 'Any'
                        : 'Asks for $_maxYears years or less',
                  ),
                  const SizedBox(height: 4),
                  Slider(
                    value: (_maxYears ?? 11).toDouble(),
                    min: 0,
                    max: 11,
                    divisions: 11,
                    label: _maxYears == null ? 'Any' : '$_maxYears yrs',
                    // The top of the track means "no ceiling" rather than
                    // "11 years", which is the more useful end state.
                    onChanged: (v) => setState(
                      () => _maxYears = v >= 11 ? null : v.round(),
                    ),
                  ),
                  Text(
                    'Postings that do not state a requirement are always shown.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(
                        const JobFilter(),
                      ),
                      child: const Text('Clear all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(
                        widget.initial.copyWith(
                          technologies: _technologies,
                          locations: _locations,
                          includeRemote: _includeRemote,
                          maxYearsExperience: _maxYears,
                          clearMaxYears: _maxYears == null,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? hint;

  const _SectionLabel(this.text, {this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: theme.textTheme.titleMedium),
        if (hint != null)
          Flexible(
            child: Text(
              hint!,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}
