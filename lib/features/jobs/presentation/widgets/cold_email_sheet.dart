import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../onboarding/domain/entities/user_profile.dart';

enum _ComposeState { composing, done }

class ColdEmailSheet extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String? jobId;
  final String? jobTitle;
  final UserProfile profile;

  const ColdEmailSheet({
    super.key,
    required this.companyId,
    required this.companyName,
    this.jobId,
    this.jobTitle,
    required this.profile,
  });

  static Future<void> show(
    BuildContext context, {
    required String companyId,
    required String companyName,
    String? jobId,
    String? jobTitle,
    required UserProfile profile,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => ColdEmailSheet(
          companyId: companyId,
          companyName: companyName,
          jobId: jobId,
          jobTitle: jobTitle,
          profile: profile,
        ),
      );

  @override
  State<ColdEmailSheet> createState() => _ColdEmailSheetState();
}

class _ColdEmailSheetState extends State<ColdEmailSheet> {
  _ComposeState _composeState = _ComposeState.composing;

  late final TextEditingController _recipientCtrl;
  late final TextEditingController _subjectCtrl;
  late final TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _recipientCtrl = TextEditingController();
    _subjectCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _composeEmail();
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _composeEmail() async {
    try {
      final api = GetIt.instance<ApiClient>();
      final endpoint = widget.jobId != null
          ? ApiEndpoints.jobComposeEmail(widget.jobId!)
          : ApiEndpoints.companyComposeEmail(widget.companyId);

      final result = await api.post(endpoint, body: {});

      if (!mounted) return;

      if (result is Map<String, dynamic>) {
        final subject = result['subject'] as String?;
        final body = result['body'] as String?;
        if (subject != null && body != null) {
          setState(() {
            _subjectCtrl.text = subject;
            _bodyCtrl.text = body;
            _composeState = _ComposeState.done;
          });
          return;
        }
      }
      _applyFallback();
    } catch (_) {
      if (mounted) _applyFallback();
    }
  }

  void _applyFallback() {
    final profile = widget.profile;
    final name = profile.name ?? '';
    final role = widget.jobTitle;
    final company = widget.companyName;
    final expLabel = profile.experienceLabel ??
        '${profile.experienceYears} year${profile.experienceYears == 1 ? '' : 's'}';

    final subject = role != null && role.isNotEmpty
        ? (name.isNotEmpty ? '$role – $name' : role)
        : (name.isNotEmpty ? 'Flutter Developer – $name' : 'Flutter Developer');

    final roleRef = role != null && role.isNotEmpty
        ? 'the $role role'
        : 'Flutter/mobile opportunities';

    final skills = profile.skills.take(5).map((s) => s.name).join(', ');

    final employerBlock = profile.currentEmployer != null
        ? 'At ${profile.currentEmployer}, I have worked on:\n\n'
            '${profile.highlights.map((h) => '- $h').join('\n')}\n\n'
        : '';

    final locationBlock = profile.locationText != null
        ? "I'm based in ${profile.locationText}, comfortable with remote work, "
            'and actively looking for a new opportunity.\n\n'
        : '';

    final body = '''Hi $company Hiring Team,

I'm writing to express my interest in $roleRef. I have $expLabel of Flutter development experience${skills.isNotEmpty ? ', with expertise in $skills' : ''}.

$employerBlock${locationBlock}Please find my resume attached.

Best regards,
${name.isNotEmpty ? name : 'Applicant'}''';

    setState(() {
      _subjectCtrl.text = subject;
      _bodyCtrl.text = body;
      _composeState = _ComposeState.done;
    });
  }

  Future<void> _openMail() async {
    final recipient = _recipientCtrl.text.trim();
    final subject = Uri.encodeComponent(_subjectCtrl.text.trim());
    final body = Uri.encodeComponent(_bodyCtrl.text.trim());
    final uri = Uri.parse('mailto:$recipient?subject=$subject&body=$body');

    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = MediaQuery.viewInsetsOf(context);
    final composing = _composeState == _ComposeState.composing;

    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
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
                  Text('Cold email', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Add recipient, review, then send.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  _Field(
                    label: 'To',
                    controller: _recipientCtrl,
                    hint: 'Paste recruiter email here',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Subject',
                    controller: _subjectCtrl,
                    hint: 'Composing…',
                    composing: composing,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    label: 'Body',
                    controller: _bodyCtrl,
                    hint: 'Composing personalised email…',
                    maxLines: 16,
                    composing: composing,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.attach_file_outlined,
                          size: 16,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attach your resume and portfolio once the email app opens.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Copy body',
                    icon: const Icon(Icons.copy_outlined, size: 20),
                    onPressed: composing
                        ? null
                        : () {
                            Clipboard.setData(
                                ClipboardData(text: _bodyCtrl.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Body copied to clipboard')),
                            );
                          },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: composing ? null : _openMail,
                      icon: const Icon(Icons.send_outlined, size: 18),
                      label: const Text('Open in email app'),
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool composing;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.composing = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (composing) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          readOnly: composing,
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
