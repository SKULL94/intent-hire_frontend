import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingShimmer({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surface,
        child: Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
