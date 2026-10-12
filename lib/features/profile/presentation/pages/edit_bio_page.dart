import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_bloc.dart';

class EditBioPage extends StatefulWidget {
  const EditBioPage({super.key});

  @override
  State<EditBioPage> createState() => _EditBioPageState();
}

class _EditBioPageState extends State<EditBioPage> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _linkedinCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _portfolioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _employerCtrl;
  late final TextEditingController _expLabelCtrl;
  late final TextEditingController _highlightInputCtrl;
  late List<String> _highlights;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    _phoneCtrl = TextEditingController(text: profile.phone ?? '');
    _linkedinCtrl = TextEditingController(text: profile.linkedinUrl ?? '');
    _githubCtrl = TextEditingController(text: profile.githubUrl ?? '');
    _portfolioCtrl = TextEditingController(text: profile.portfolioUrl ?? '');
    _locationCtrl = TextEditingController(text: profile.locationText ?? '');
    _employerCtrl = TextEditingController(text: profile.currentEmployer ?? '');
    _expLabelCtrl = TextEditingController(text: profile.experienceLabel ?? '');
    _highlightInputCtrl = TextEditingController();
    _highlights = List<String>.from(profile.highlights);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _linkedinCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _locationCtrl.dispose();
    _employerCtrl.dispose();
    _expLabelCtrl.dispose();
    _highlightInputCtrl.dispose();
    super.dispose();
  }

  void _addHighlight() {
    final text = _highlightInputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _highlights.add(text);
      _highlightInputCtrl.clear();
    });
  }

  void _removeHighlight(int index) {
    setState(() => _highlights.removeAt(index));
  }

  void _save() {
    final bloc = context.read<ProfileBloc>();
    bloc.add(ProfileBioChanged(
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      linkedinUrl: _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
      githubUrl: _githubCtrl.text.trim().isEmpty ? null : _githubCtrl.text.trim(),
      portfolioUrl: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
      locationText: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      currentEmployer: _employerCtrl.text.trim().isEmpty ? null : _employerCtrl.text.trim(),
      highlights: List.unmodifiable(_highlights),
      experienceLabel: _expLabelCtrl.text.trim().isEmpty ? null : _expLabelCtrl.text.trim(),
    ));
    bloc.add(const ProfileSaved());
  }

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
        final saving = state.status == ProfileStatus.saving;

        return Scaffold(
          appBar: AppBar(title: const Text('Bio & contacts')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Cold-email signature',
                children: [
                  _LabelledField(
                    label: 'Experience label',
                    hint: 'e.g. 4.7+ years',
                    controller: _expLabelCtrl,
                  ),
                  const SizedBox(height: 12),
                  _LabelledField(
                    label: 'Phone',
                    hint: '+91-XXXXXXXXXX',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _LabelledField(
                    label: 'LinkedIn URL',
                    hint: 'https://linkedin.com/in/…',
                    controller: _linkedinCtrl,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  _LabelledField(
                    label: 'GitHub URL',
                    hint: 'https://github.com/…',
                    controller: _githubCtrl,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  _LabelledField(
                    label: 'Portfolio URL',
                    hint: 'https://…',
                    controller: _portfolioCtrl,
                    keyboardType: TextInputType.url,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Work context',
                children: [
                  _LabelledField(
                    label: 'Current / most recent employer',
                    hint: 'e.g. Quokka Labs',
                    controller: _employerCtrl,
                  ),
                  const SizedBox(height: 12),
                  _LabelledField(
                    label: 'Location',
                    hint: 'e.g. Noida, Uttar Pradesh',
                    controller: _locationCtrl,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _HighlightsSection(
                highlights: _highlights,
                controller: _highlightInputCtrl,
                onAdd: _addHighlight,
                onRemove: _removeHighlight,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: saving ? null : _save,
                child: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _LabelledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabelledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  final List<String> highlights;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _HighlightsSection({
    required this.highlights,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Highlights', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Bullet points the AI picks from when writing your cold email.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < highlights.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12, right: 8),
                  child: Text('•'),
                ),
                Expanded(
                  child: Text(
                    highlights[i],
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onRemove(i),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'e.g. REST API and third-party service integration',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
