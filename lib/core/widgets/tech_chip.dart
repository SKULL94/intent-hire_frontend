import 'package:flutter/material.dart';

class TechChip extends StatelessWidget {
  final String tech;
  final double? confidence;
  final bool matched;

  const TechChip({
    super.key,
    required this.tech,
    this.confidence,
    this.matched = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = matched ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = matched ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        confidence == null
            ? tech
            : '$tech ${(confidence! * 100).round()}%',
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
