import 'package:flutter_test/flutter_test.dart';
import 'package:hiring_intent/features/companies/domain/entities/company_filter.dart';

void main() {
  group('CompanyFilter', () {
    test('defaults answer the question as asked', () {
      const f = CompanyFilter.initial;
      expect(f.flutterOnly, isTrue);
      expect(f.ncrOrRemote, isTrue);
      // Off by default: with no overlap between funding and Flutter evidence
      // yet, starting it on would show an empty list.
      expect(f.hiringSoon, isFalse);
    });

    test('builds the query the API expects', () {
      const f = CompanyFilter(
        flutterOnly: true,
        ncrOrRemote: false,
        hiringSoon: true,
      );
      expect(f.toQuery(limit: 30, offset: 60), {
        'flutter_only': true,
        'ncr_or_remote': false,
        'hiring_soon': true,
        'limit': 30,
        'offset': 60,
      });
    });

    test('survives a JSON round trip', () {
      const f = CompanyFilter(
        flutterOnly: false,
        ncrOrRemote: true,
        hiringSoon: true,
      );
      expect(CompanyFilter.fromJson(f.toJson()), f);
    });

    test('a stored value missing keys falls back to the defaults', () {
      final f = CompanyFilter.fromJson(const {});
      expect(f, CompanyFilter.initial);
    });

    test('copyWith changes only what is named', () {
      const f = CompanyFilter.initial;
      final changed = f.copyWith(hiringSoon: true);
      expect(changed.hiringSoon, isTrue);
      expect(changed.flutterOnly, f.flutterOnly);
      expect(changed.ncrOrRemote, f.ncrOrRemote);
    });

    test('activeCount reflects the switches that are on', () {
      expect(CompanyFilter.initial.activeCount, 2);
      expect(
        const CompanyFilter(
          flutterOnly: false,
          ncrOrRemote: false,
          hiringSoon: false,
        ).activeCount,
        0,
      );
    });
  });
}
