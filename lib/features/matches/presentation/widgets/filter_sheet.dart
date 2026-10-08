import 'package:flutter/material.dart';

import '../../domain/repositories/matches_repository.dart';

/// Bottom sheet for the `min_score` / `min_tech_fit` query parameters the
/// matches endpoint accepts. Returns the new filter, or null if dismissed.
class FilterSheet extends StatefulWidget {
  final MatchFilter initial;

  const FilterSheet({super.key, required this.initial});

  static Future<MatchFilter?> show(BuildContext context, MatchFilter initial) =>
      showModalBottomSheet<MatchFilter>(
        context: context,
        isScrollControlled: true,
        builder: (_) => FilterSheet(initial: initial),
      );

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _minScore = widget.initial.minScore;
  late double _minTechFit = widget.initial.minTechFit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Filter matches', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            _Slider(
              label: 'Minimum match score',
              value: _minScore,
              max: 100,
              display: _minScore.round().toString(),
              onChanged: (v) => setState(() => _minScore = v),
            ),
            const SizedBox(height: 12),
            _Slider(
              label: 'Minimum stack fit',
              value: _minTechFit,
              max: 1,
              display: '${(_minTechFit * 100).round()}%',
              onChanged: (v) => setState(() => _minTechFit = v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(
                      widget.initial.copyWith(minScore: 0, minTechFit: 0),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      widget.initial.copyWith(
                        minScore: _minScore,
                        minTechFit: _minTechFit,
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final String display;
  final ValueChanged<double> onChanged;

  const _Slider({
    required this.label,
    required this.value,
    required this.max,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(display, style: theme.textTheme.titleSmall),
          ],
        ),
        Slider(
          value: value.clamp(0, max),
          max: max,
          divisions: 20,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
