import 'package:flutter/material.dart';

import '../../domain/entities/company_filter.dart';

/// The three switches, as chips, always visible.
///
/// They are the question itself rather than secondary refinement, so they sit
/// on the screen instead of behind a filter sheet — the user should be able to
/// see why the list contains what it contains.
class FilterBar extends StatelessWidget {
  final CompanyFilter filter;
  final ValueChanged<CompanyFilter> onChanged;

  const FilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Chip(
            label: 'Builds Flutter',
            icon: Icons.flutter_dash,
            selected: filter.flutterOnly,
            onSelected: (v) => onChanged(filter.copyWith(flutterOnly: v)),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'NCR or remote',
            icon: Icons.place_outlined,
            selected: filter.ncrOrRemote,
            onSelected: (v) => onChanged(filter.copyWith(ncrOrRemote: v)),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'About to hire',
            icon: Icons.trending_up,
            selected: filter.hiringSoon,
            onSelected: (v) => onChanged(filter.copyWith(hiringSoon: v)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 18),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
    );
  }
}
