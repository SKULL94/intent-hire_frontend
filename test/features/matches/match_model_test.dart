import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiring_intent/features/matches/data/models/match_model.dart';
import 'package:hiring_intent/features/matches/domain/entities/match.dart';

/// Captured verbatim from a live `GET /api/v1/matches` response, so this test
/// fails if the backend contract drifts from what the parser expects.
const String _realPayload = '''
{
  "id": "eaba588c-bb1c-4aee-8ac4-9491b5617398",
  "user_id": "2e347123-e172-4ff8-933f-e9a1aa19d76a",
  "company_id": "e35b523a-b4ae-4123-8e34-a2a98d30bbe0",
  "score": 31.4324,
  "tech_fit": 0.262203,
  "intent_score": 39.2506,
  "top_signals": [
    {
      "source": "github:discord:new_repos",
      "confidence": 0.5,
      "detected_at": "2026-10-08T05:18:43.066728+00:00",
      "signal_type": "github_activity"
    },
    {
      "source": "greenhouse:discord",
      "confidence": 1.0,
      "detected_at": "2026-10-06T12:43:32.197782+00:00",
      "signal_type": "ats_job"
    }
  ],
  "status": "new",
  "matched_at": "2026-10-08T05:23:33.345246Z",
  "company": {
    "id": "e35b523a-b4ae-4123-8e34-a2a98d30bbe0",
    "name": "Discord",
    "domain": "discord.com",
    "careers_url": "https://discord.com/careers",
    "ats_type": "greenhouse",
    "ats_slug": "discord",
    "github_org": "discord",
    "app_package_id": null,
    "employee_count": null,
    "industry": null,
    "location": null,
    "website": null,
    "logo_url": null,
    "is_active": true,
    "created_at": "2026-10-06T12:40:00Z",
    "updated_at": "2026-10-08T05:23:00Z"
  },
  "company_score": {
    "intent_score": 39.2506,
    "stack_fingerprint": {"rust": 0.95, "python": 0.9, "go": 1, "react": 0.9},
    "signal_count": 2,
    "strongest_signal": "ats_job",
    "last_scored_at": "2026-10-08T05:23:00Z"
  }
}
''';

Map<String, dynamic> _payload() =>
    jsonDecode(_realPayload) as Map<String, dynamic>;

void main() {
  group('MatchModel.fromJson', () {
    test('parses the live matches payload', () {
      final match = MatchModel.fromJson(_payload());

      expect(match.id, 'eaba588c-bb1c-4aee-8ac4-9491b5617398');
      expect(match.score, closeTo(31.4324, 1e-6));
      expect(match.techFit, closeTo(0.262203, 1e-6));
      expect(match.status, MatchStatus.newMatch);
      expect(match.company.name, 'Discord');
      expect(match.company.hasReachableAts, isTrue);
      expect(match.topSignals, hasLength(2));
      expect(match.topSignals.first.signalType, 'github_activity');
    });

    test('normalizes int confidences in the stack fingerprint to double', () {
      final match = MatchModel.fromJson(_payload());
      // "go": 1 arrives as an int in JSON.
      expect(match.company.stackFingerprint['go'], 1.0);
      expect(match.company.stackFingerprint['rust'], 0.95);
    });

    test('ranks the stack strongest-first', () {
      final match = MatchModel.fromJson(_payload());
      expect(match.company.rankedStack.first.$1, 'go');
    });

    test('reports which of the user skills the company covers', () {
      final match = MatchModel.fromJson(_payload());
      expect(
        match.matchedSkills({'python', 'flutter', 'dart'}),
        {'python'},
      );
    });

    test('ats_type "other" means no readable job board', () {
      final json = _payload();
      (json['company'] as Map<String, dynamic>)['ats_type'] = 'other';
      expect(MatchModel.fromJson(json).company.hasReachableAts, isFalse);
    });

    test('survives a payload with no score and no signals', () {
      final json = _payload()
        ..remove('company_score')
        ..['top_signals'] = null;
      final match = MatchModel.fromJson(json);

      expect(match.company.stackFingerprint, isEmpty);
      expect(match.topSignals, isEmpty);
      expect(match.company.signalCount, 0);
    });
  });
}
