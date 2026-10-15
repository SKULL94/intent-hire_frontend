import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/tech_chip.dart';
import '../../domain/entities/company.dart';
import '../bloc/company_detail_bloc.dart';
import '../widgets/evidence_badge.dart';

class CompanyDetailPage extends StatelessWidget {
  final String companyId;

  const CompanyDetailPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyDetailBloc, CompanyDetailStateData>(
      builder: (context, state) {
        final company = state.company;
        return Scaffold(
          appBar: AppBar(title: Text(company?.name ?? 'Company')),
          body: switch (state.status) {
            CompanyDetailStatus.initial ||
            CompanyDetailStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            CompanyDetailStatus.failure => EmptyState(
                icon: Icons.cloud_off,
                title: 'Could not load this company',
                message: state.error,
                action: FilledButton(
                  onPressed: () => context
                      .read<CompanyDetailBloc>()
                      .add(CompanyDetailRequested(companyId)),
                  child: const Text('Try again'),
                ),
              ),
            CompanyDetailStatus.success =>
              company == null ? const SizedBox.shrink() : _Body(company),
          },
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  final Company company;
  const _Body(this.company);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // --- identity -----------------------------------------------------
        Text(company.name, style: text.headlineSmall),
        if (company.location != null || company.industry != null) ...[
          const SizedBox(height: 4),
          Text(
            [company.location, company.industry]
                .whereType<String>()
                .join(' · '),
            style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
        if (company.hasProof) ...[
          const SizedBox(height: 12),
          const _ProofBanner(),
        ],

        // --- links --------------------------------------------------------
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (company.website != null)
              _LinkButton(
                icon: Icons.language,
                label: 'Website',
                url: company.website!,
              ),
            if (company.careersUrl != null)
              _LinkButton(
                icon: Icons.work_outline,
                label: 'Careers',
                url: company.careersUrl!,
              ),
            if (company.appPackageId != null)
              _LinkButton(
                icon: Icons.phone_android,
                label: 'Play Store',
                url:
                    'https://play.google.com/store/apps/details?id=${company.appPackageId}',
              ),
            if (company.domain != null)
              _LinkButton(
                icon: Icons.search,
                label: 'Find people',
                url:
                    'https://www.google.com/search?q=${Uri.encodeQueryComponent('"${company.name}" flutter developer linkedin')}',
              ),
          ],
        ),

        // --- why it is in the list ----------------------------------------
        const SizedBox(height: 28),
        const _SectionTitle(
          'Why this company is listed',
          subtitle: 'Evidence they build in Flutter, strongest first',
        ),
        const SizedBox(height: 12),
        if (company.evidence.isEmpty)
          const _Muted('No Flutter evidence recorded.')
        else
          ...company.rankedEvidence.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EvidenceBadge(evidence: e),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 4),
                    child: Text(
                      'Observed ${timeago.format(e.observedAt)}',
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // --- about to hire -------------------------------------------------
        const SizedBox(height: 12),
        const _SectionTitle(
          'Hiring signals',
          subtitle: 'Events that tend to precede a posting',
        ),
        const SizedBox(height: 12),
        if (company.hiringSignals.isEmpty)
          const _Muted(
            'Nothing yet. Funding rounds and new app releases show up here '
            'weeks before a role is posted.',
          )
        else
          ...company.rankedSignals.map((s) => _SignalRow(signal: s)),

        // --- stack ---------------------------------------------------------
        if (company.technologies.isNotEmpty) ...[
          const SizedBox(height: 28),
          const _SectionTitle(
            'Technologies seen',
            subtitle: 'Across every posting and artefact we read',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: company.technologies
                .map((t) => TechChip(
                      tech: t.$1,
                      confidence: t.$2,
                      matched: t.$1 == 'flutter' || t.$1 == 'dart',
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _ProofBanner extends StatelessWidget {
  const _ProofBanner();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.success.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppColors.success.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Proven Flutter shop — evidence comes from something they '
              'shipped, not a job description.',
              style: text.bodySmall?.copyWith(color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final HiringSignal signal;
  const _SignalRow({required this.signal});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final url = signal.url;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.trending_up, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.kind.label,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    timeago.format(signal.observedAt),
                    if (signal.kind.leadTime != null)
                      'typically leads a posting by ${signal.kind.leadTime}',
                  ].join(' · '),
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (url != null)
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _open(url),
                    child: const Text('Read the announcement'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleMedium),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle!,
              style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _Muted extends StatelessWidget {
  final String message;
  const _Muted(this.message);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      style: theme.textTheme.bodyMedium
          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _open(url),
      icon: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

Future<void> _open(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
