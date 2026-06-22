import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

(int interval, double easeFactor, int repetitions) _calculateSm2({
  required double easeFactor,
  required int interval,
  required int repetitions,
  required int quality,
}) {
  final safeQuality = quality.clamp(0, 5);
  final adjustedEaseFactor = max(
    1.3,
    easeFactor + 0.1 - (5 - safeQuality) * (0.08 + (5 - safeQuality) * 0.02),
  );
  final adjustedRepetitions = safeQuality < 3 ? 0 : repetitions + 1;
  int adjustedInterval;

  if (safeQuality < 3) {
    adjustedInterval = 1;
  } else if (adjustedRepetitions == 1) {
    adjustedInterval = 1;
  } else if (adjustedRepetitions == 2) {
    adjustedInterval = 6;
  } else {
    adjustedInterval = max(1, (interval * adjustedEaseFactor).round());
  }

  return (adjustedInterval, adjustedEaseFactor, adjustedRepetitions);
}

void main() {
  group('SM-2 algorithm', () {
    test('quality 0 resets interval to 1 regardless of previous interval', () {
      final (interval, _, repetitions) = _calculateSm2(
        easeFactor: 2.5,
        interval: 10,
        repetitions: 5,
        quality: 0,
      );
      expect(interval, equals(1));
      expect(repetitions, equals(0));
    });

    test('quality 1 resets interval to 1', () {
      final (interval, _, repetitions) = _calculateSm2(
        easeFactor: 2.5,
        interval: 20,
        repetitions: 3,
        quality: 1,
      );
      expect(interval, equals(1));
      expect(repetitions, equals(0));
    });

    test('quality 2 resets interval to 1', () {
      final (interval, _, repetitions) = _calculateSm2(
        easeFactor: 2.5,
        interval: 100,
        repetitions: 10,
        quality: 2,
      );
      expect(interval, equals(1));
      expect(repetitions, equals(0));
    });

    test('quality >= 3 increments repetitions counter', () {
      final (_, _, repetitions) = _calculateSm2(
        easeFactor: 2.5,
        interval: 0,
        repetitions: 5,
        quality: 3,
      );
      expect(repetitions, equals(6));
    });

    test('quality 5 increments repetitions counter', () {
      final (_, _, repetitions) = _calculateSm2(
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: 5,
      );
      expect(repetitions, equals(1));
    });

    test('first review with quality >= 3 gives interval 1', () {
      final (interval, _, _) = _calculateSm2(
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: 3,
      );
      expect(interval, equals(1));
    });

    test('second review with quality >= 3 gives interval 6', () {
      final (interval, _, _) = _calculateSm2(
        easeFactor: 2.5,
        interval: 1,
        repetitions: 1,
        quality: 4,
      );
      expect(interval, equals(6));
    });

    test('third review uses SM-2 multiplier formula', () {
      final (interval, _, _) = _calculateSm2(
        easeFactor: 2.5,
        interval: 6,
        repetitions: 2,
        quality: 4,
      );
      expect(interval, equals((6 * 2.5).round()));
    });

    test('easeFactor never drops below 1.3 regardless of quality', () {
      double ef = 2.5;
      for (final quality in [0, 1, 2]) {
        for (int i = 0; i < 50; i++) {
          final result = _calculateSm2(
            easeFactor: ef,
            interval: 1,
            repetitions: 0,
            quality: quality,
          );
          ef = result.$2;
          expect(ef, greaterThanOrEqualTo(1.3));
        }
      }
    });

    test('easeFactor never drops below 1.3 with extreme inputs', () {
      final (_, ef, _) = _calculateSm2(
        easeFactor: 1.3,
        interval: 1,
        repetitions: 0,
        quality: 0,
      );
      expect(ef, greaterThanOrEqualTo(1.3));
    });

    test('easeFactor stays above 1.3 after many quality=0 reviews', () {
      double ef = 2.5;
      for (int i = 0; i < 100; i++) {
        final result = _calculateSm2(
          easeFactor: ef,
          interval: 1,
          repetitions: 0,
          quality: 0,
        );
        ef = result.$2;
      }
      expect(ef, greaterThanOrEqualTo(1.3));
    });

    test('nextDueAt is always in the future after any review', () {
      final now = DateTime.now();
      for (final quality in [0, 1, 2, 3, 4, 5]) {
        for (final interval in [0, 1, 6, 10, 100]) {
          for (final reps in [0, 1, 2, 5]) {
            final (adjustedInterval, _, _) = _calculateSm2(
              easeFactor: 2.5,
              interval: interval,
              repetitions: reps,
              quality: quality,
            );
            final dueAt = now.add(Duration(days: adjustedInterval));
            expect(dueAt.isAfter(now), isTrue,
                reason:
                    'quality=$quality interval=$interval reps=$reps produced adjustedInterval=$adjustedInterval');
          }
        }
      }
    });
  });
}
