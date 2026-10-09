import 'package:flutter_test/flutter_test.dart';
import 'package:hiring_intent/features/matches/data/datasources/match_filter_store.dart';
import 'package:hiring_intent/features/matches/domain/repositories/matches_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<MatchFilterStore> _store([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  return MatchFilterStore(await SharedPreferences.getInstance());
}

void main() {
  group('MatchFilterStore', () {
    test('returns the default filter on a fresh install', () async {
      final store = await _store();
      final filter = store.read();

      expect(filter.minScore, 0);
      expect(filter.minTechFit, 0);
      expect(filter.isDefault, isTrue);
    });

    test('restores what was written', () async {
      final store = await _store();
      await store.write(const MatchFilter(minScore: 45, minTechFit: 0.3));

      final filter = store.read();
      expect(filter.minScore, 45);
      expect(filter.minTechFit, 0.3);
      expect(filter.isDefault, isFalse);
    });

    test('keeps the default limit, which the filter sheet cannot edit', () async {
      final store = await _store();
      await store.write(const MatchFilter(minScore: 70, minTechFit: 0.5));

      expect(store.read().limit, const MatchFilter().limit);
    });

    test('a reset back to zero persists as zero, not as "nothing stored"',
        () async {
      final store = await _store();
      await store.write(const MatchFilter(minScore: 80, minTechFit: 0.9));
      await store.write(const MatchFilter());

      expect(store.read().isDefault, isTrue);
    });

    test('reads values left by a previous session', () async {
      // Keys are a storage contract: renaming them silently drops a user's
      // saved filter, so pin the literal strings here.
      final store = await _store({
        'flutter.matches.min_score': 60.0,
        'flutter.matches.min_tech_fit': 0.25,
      });

      final filter = store.read();
      expect(filter.minScore, 60);
      expect(filter.minTechFit, 0.25);
    });
  });
}
