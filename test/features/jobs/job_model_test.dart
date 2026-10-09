import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiring_intent/features/jobs/data/models/job_model.dart';
import 'package:hiring_intent/features/jobs/domain/entities/job.dart';

/// Captured verbatim from a live `GET /api/v1/jobs?tech=flutter&location=delhi_ncr`,
/// so this test fails if the backend contract drifts from what the parser expects.
const String _realPayload = '''
{
  "id": "c5aa823c-395a-4c47-be95-8a68f4a14044",
  "company_id": "f383584e-9df0-456f-b035-610f22d102f7",
  "source": "adzuna",
  "title": "Flutter Android/iOS App Development",
  "url": "https://www.adzuna.in/details/5920569465",
  "department": "IT Jobs",
  "description": "The candidate will be directly working in the area of app development",
  "location_raw": "Delhi, India",
  "location_normalized": "delhi_ncr",
  "is_remote": false,
  "technologies": {"ios": 0.95, "android": 0.95, "flutter": 0.95},
  "min_years_experience": null,
  "salary_min": 120000.0,
  "salary_max": 9600000.0,
  "contract_time": "full_time",
  "posted_at": "2026-10-09T17:57:01Z",
  "last_seen_at": "2026-10-09T15:34:17.262998Z",
  "company": {
    "id": "f383584e-9df0-456f-b035-610f22d102f7",
    "name": "Neuraltechwork",
    "domain": null,
    "logo_url": null,
    "careers_url": null
  },
  "company_intent_score": null
}
''';

Job _parse(String json) =>
    JobModel.fromJson(jsonDecode(json) as Map<String, dynamic>);

void main() {
  group('JobModel.fromJson', () {
    test('parses the live jobs payload', () {
      final job = _parse(_realPayload);

      expect(job.title, 'Flutter Android/iOS App Development');
      expect(job.source, 'adzuna');
      expect(job.company.name, 'Neuraltechwork');
      expect(job.locationNormalized, JobLocations.delhiNcr);
      expect(job.isRemote, isFalse);
      expect(job.technologies['flutter'], 0.95);
      expect(job.contractTime, 'full_time');
      expect(job.minYearsExperience, isNull);
      expect(job.companyIntentScore, isNull);
    });

    test('renders Indian salaries in lakhs, not raw rupees', () {
      // 120000 and 9600000 rupees are unreadable on a card.
      expect(_parse(_realPayload).salaryLabel, '₹1–96L');
    });

    test('a single-value salary range does not read as a range', () {
      final job = _parse(_realPayload.replaceFirst('9600000.0', '120000.0'));
      expect(job.salaryLabel, '₹1L');
    });

    test('no salary means no label rather than a zero', () {
      final job = _parse(
        _realPayload
            .replaceFirst('"salary_min": 120000.0', '"salary_min": null')
            .replaceFirst('"salary_max": 9600000.0', '"salary_max": null'),
      );
      expect(job.hasSalary, isFalse);
      expect(job.salaryLabel, isNull);
    });

    test('normalizes int confidences to double', () {
      final job = _parse(
        _realPayload.replaceFirst('"flutter": 0.95', '"flutter": 1'),
      );
      expect(job.technologies['flutter'], 1.0);
    });

    test('ranks technologies strongest-first', () {
      final job = _parse(
        _realPayload.replaceFirst(
          '{"ios": 0.95, "android": 0.95, "flutter": 0.95}',
          '{"ios": 0.3, "flutter": 0.95, "android": 0.7}',
        ),
      );
      expect(job.rankedTechnologies.first.$1, 'flutter');
      expect(job.rankedTechnologies.last.$1, 'ios');
    });

    test('reports which of the user skills this posting asks for', () {
      final job = _parse(_realPayload);
      expect(job.matchedSkills({'Flutter', 'python'}), {'flutter'});
    });

    test('falls back to the raw location for display', () {
      expect(_parse(_realPayload).locationLabel, 'Delhi, India');
    });

    test('survives a payload with nulls and a missing company', () {
      final job = _parse('''
      {
        "id": "x", "company_id": "y", "source": "greenhouse",
        "title": "Engineer", "last_seen_at": "2026-10-09T15:34:17Z",
        "technologies": {}, "company": {}
      }
      ''');
      expect(job.company.name, 'Unknown company');
      expect(job.technologies, isEmpty);
      expect(job.isRemote, isFalse);
      expect(job.locationLabel, 'Location not stated');
    });
  });
}
