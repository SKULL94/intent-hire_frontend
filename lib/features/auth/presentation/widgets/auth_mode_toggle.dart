import 'package:flutter/material.dart';

enum AuthMode { email, phone }

class AuthModeToggle extends StatelessWidget {
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  const AuthModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AuthMode>(
      segments: const [
        ButtonSegment(
          value: AuthMode.email,
          label: Text('Email'),
          icon: Icon(Icons.email_outlined),
        ),
        ButtonSegment(
          value: AuthMode.phone,
          label: Text('Phone'),
          icon: Icon(Icons.phone_outlined),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
