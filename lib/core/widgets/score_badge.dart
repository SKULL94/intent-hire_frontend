import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class ScoreBadge extends StatelessWidget {
  final double score;
  final double size;

  const ScoreBadge({
    super.key,
    required this.score,
    this.size = 48,
  });

  Color _colorFor(double value) {
    if (value >= AppConstants.highScoreThreshold) return AppColors.success;
    if (value >= AppConstants.medScoreThreshold) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final clamped = score.clamp(0.0, 100.0);
    final color = _colorFor(clamped);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: clamped / 100.0,
              strokeWidth: 4,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            clamped.round().toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: size * 0.32,
            ),
          ),
        ],
      ),
    );
  }
}
