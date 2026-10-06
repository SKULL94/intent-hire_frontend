import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum SignalIconKind {
  atsJob,
  funding,
  news,
  hnWhosHiring,
  githubActivity,
}

class SignalIcon extends StatelessWidget {
  final SignalIconKind kind;
  final double size;

  const SignalIcon({
    super.key,
    required this.kind,
    this.size = 20,
  });

  (IconData, Color) _resolve() => switch (kind) {
        SignalIconKind.atsJob =>
          (Icons.description_outlined, AppColors.primary),
        SignalIconKind.funding => (Icons.payments_outlined, AppColors.success),
        SignalIconKind.news => (Icons.newspaper_outlined, AppColors.info),
        SignalIconKind.hnWhosHiring => (Icons.forum_outlined, AppColors.warning),
        SignalIconKind.githubActivity => (Icons.code, Colors.grey),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _resolve();
    return Icon(icon, size: size, color: color);
  }
}
