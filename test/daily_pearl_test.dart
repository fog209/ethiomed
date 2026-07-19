import 'package:flutter_test/flutter_test.dart';

import 'package:ethiomed/features/articles/data/daily_pearl.dart';

List<PearlCandidate> _candidates(int count) => [
      for (var i = 0; i < count; i++)
        PearlCandidate(
          articleId: 'a$i',
          articleTitle: 'Article $i',
          sectionKey: 'clinicalPearls',
          body: 'Pearl body $i',
        ),
    ];

void main() {
  group('pickDailyPearl', () {
    test('returns null when there is no eligible content', () {
      expect(pickDailyPearl(<PearlCandidate>[], DateTime(2026, 7, 19)), isNull);
    });

    test('same date always yields the same pearl', () {
      final candidates = _candidates(5);
      final day = DateTime(2026, 7, 19);
      final firstId = pickDailyPearl(candidates, day)?.articleId;
      for (var i = 0; i < 10; i++) {
        expect(pickDailyPearl(candidates, day)?.articleId, equals(firstId));
      }
    });

    test('a different date can yield a different pearl', () {
      final candidates = _candidates(3);
      final dayA = DateTime(2026, 1, 1); // dayNumber % 3 == 0
      final dayB = DateTime(2026, 1, 2); // dayNumber % 3 == 1
      final pearlA = pickDailyPearl(candidates, dayA);
      final pearlB = pickDailyPearl(candidates, dayB);
      expect(pearlA?.articleId, isNot(equals(pearlB?.articleId)));
    });

    test('selection index wraps with modulo candidate count', () {
      final candidates = _candidates(2);
      final day0 = DateTime(1970, 1, 1); // dayNumber 0 -> index 0
      final day2 = DateTime(1970, 1, 3); // dayNumber 2 -> index 0 (wraps)
      expect(
        pickDailyPearl(candidates, day0)?.articleId,
        equals(pickDailyPearl(candidates, day2)?.articleId),
      );
    });
  });
}
