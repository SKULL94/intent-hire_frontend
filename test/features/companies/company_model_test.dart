import 'package:flutter_test/flutter_test.dart';
import 'package:hiring_intent/features/companies/data/models/company_model.dart';
import 'package:hiring_intent/features/companies/domain/entities/company.dart';

/// A list row: `/api/v1/companies` returns no evidence, only the company.
Map<String, dynamic> _listRow() => {
      'id': 'c1',
      'name': 'Yudiz Solutions',
      'domain': 'yudiz.com',
      'location': 'Ahmedabad',
      'website': 'https://yudiz.com',
      'careers_url': null,
      'industry': null,
      'employee_count': null,
      'play_store_dev_id': null,
      'app_package_id': null,
      'is_active': true,
      'created_at': '2026-10-01T00:00:00Z',
      'updated_at': '2026-10-01T00:00:00Z',
    };

Map<String, dynamic> _detailRow() => {
      ..._listRow(),
      'stack_signals': [
        {
          'source_type': 'ats_job_nlp',
          'source_url': null,
          'technologies': {'flutter': 0.95, 'dart': 0.95},
          'raw_evidence': 'Synthesised from 2 adzuna Flutter/Dart postings',
          'detected_at': '2026-10-10T00:00:00Z',
        },
        {
          'source_type': 'apk',
          'source_url': 'https://play.google.com/store/apps/details?id=com.x',
          'technologies': {'flutter': 1.0},
          'raw_evidence': 'libflutter.so present',
          'detected_at': '2026-10-05T00:00:00Z',
        },
        // Stack evidence for an unrelated technology. The company is not in
        // the list because of this, so it must not be shown as Flutter proof.
        {
          'source_type': 'ats_job_nlp',
          'source_url': null,
          'technologies': {'react': 0.95},
          'raw_evidence': 'react role',
          'detected_at': '2026-10-11T00:00:00Z',
        },
      ],
      'intent_signals': [
        {
          'signal_type': 'funding',
          'source': 'https://inc42.com/some-round',
          'confidence': 0.95,
          'detected_at': '2026-09-20T00:00:00Z',
        },
        {
          'signal_type': 'ats_job',
          'source': 'adzuna:flutter_jobs',
          'confidence': 1.0,
          'detected_at': '2026-10-12T00:00:00Z',
        },
      ],
    };

void main() {
  group('CompanyModel.fromJson', () {
    test('parses a list row with no evidence attached', () {
      final company = CompanyModel.fromJson(_listRow());
      expect(company.id, 'c1');
      expect(company.name, 'Yudiz Solutions');
      expect(company.domain, 'yudiz.com');
      expect(company.evidence, isEmpty);
      expect(company.hiringSignals, isEmpty);
      expect(company.hasProof, isFalse);
    });

    test('blank strings are treated as absent, not shown as empty text', () {
      final company = CompanyModel.fromJson({
        ..._listRow(),
        'domain': '   ',
        'location': '',
      });
      expect(company.domain, isNull);
      expect(company.location, isNull);
    });

    test('drops evidence that names no Flutter technology', () {
      final company = CompanyModel.fromJson(_detailRow());
      // The react-only observation must not survive.
      expect(company.evidence.length, 2);
      expect(
        company.evidence.every((e) =>
            e.technologies.containsKey('flutter') ||
            e.technologies.containsKey('dart')),
        isTrue,
      );
    });

    test('recognises shipped-artefact evidence as proof', () {
      final company = CompanyModel.fromJson(_detailRow());
      expect(company.hasProof, isTrue);
      // Proof outranks a job title even though the title is newer.
      expect(company.bestEvidence?.kind, EvidenceKind.apk);
    });

    test('a job-title-only company is listed but not proven', () {
      final json = _detailRow();
      json['stack_signals'] = [
        {
          'source_type': 'ats_job_nlp',
          'technologies': {'flutter': 0.95},
          'detected_at': '2026-10-10T00:00:00Z',
        },
      ];
      final company = CompanyModel.fromJson(json);
      expect(company.evidence, hasLength(1));
      expect(company.hasProof, isFalse);
      expect(company.bestEvidence?.kind, EvidenceKind.jobTitle);
    });

    test('maps unknown wire values to a safe fallback', () {
      final json = _detailRow();
      json['stack_signals'] = [
        {
          'source_type': 'something_new',
          'technologies': {'flutter': 0.9},
          'detected_at': '2026-10-10T00:00:00Z',
        },
      ];
      json['intent_signals'] = [
        {
          'signal_type': 'something_new',
          'source': 'x',
          'confidence': 0.5,
          'detected_at': '2026-10-10T00:00:00Z',
        },
      ];
      final company = CompanyModel.fromJson(json);
      expect(company.evidence.first.kind, EvidenceKind.unknown);
      expect(company.hiringSignals.first.kind, HiringSignalKind.unknown);
    });

    test('latest hiring signal wins regardless of input order', () {
      final company = CompanyModel.fromJson(_detailRow());
      expect(company.latestSignal?.kind, HiringSignalKind.posting);
    });

    test('exposes a URL only for signals that carry one', () {
      final company = CompanyModel.fromJson(_detailRow());
      final funding = company.hiringSignals
          .firstWhere((s) => s.kind == HiringSignalKind.funding);
      final posting = company.hiringSignals
          .firstWhere((s) => s.kind == HiringSignalKind.posting);
      expect(funding.url, 'https://inc42.com/some-round');
      // "adzuna:flutter_jobs" is an opaque token, not a link to offer.
      expect(posting.url, isNull);
    });

    test('merges technologies across evidence, keeping the best confidence',
        () {
      final company = CompanyModel.fromJson(_detailRow());
      final flutter = company.technologies.firstWhere((t) => t.$1 == 'flutter');
      expect(flutter.$2, 1.0);
      // Sorted strongest first.
      expect(company.technologies.first.$1, 'flutter');
    });
  });

  group('CompanyModel.listFromJson', () {
    test('parses a page', () {
      final list = CompanyModel.listFromJson([_listRow(), _listRow()]);
      expect(list, hasLength(2));
    });

    test('a non-list payload yields an empty page rather than throwing', () {
      expect(CompanyModel.listFromJson(null), isEmpty);
      expect(CompanyModel.listFromJson(<String, dynamic>{}), isEmpty);
    });
  });
}
