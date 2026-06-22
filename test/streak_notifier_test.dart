import 'package:flutter_test/flutter_test.dart';

/// Pure streak calculation: given a list of (dateString YYYY-MM-DD, articlesRead),
/// returns the current streak starting from today going backwards.
///
/// A day counts only if a session exists AND articlesRead > 0.
/// If any day in the consecutive range is missing (gap), streak resets to 0.
int calculateStreak({
  required List<(String date, int articlesRead)> sessions,
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final todayKey =
      DateTime(today.year, today.month, today.day).toIso8601String().substring(
        0,
        10,
      );

  final activeDays = <String>{};
  for (final (date, articlesRead) in sessions) {
    if (articlesRead > 0) {
      activeDays.add(date);
    }
  }

  if (!activeDays.contains(todayKey)) return 0;

  final sorted = activeDays.toList()..sort();
  for (int i = 0; i < sorted.length - 1; i++) {
    final current = DateTime.parse(sorted[i]);
    final next = DateTime.parse(sorted[i + 1]);
    if (current.difference(next).inDays.abs() != 1) return 0;
  }

  return activeDays.length;
}

void main() {
  group('Streak calculation', () {
    test('empty session list returns streak of 0', () {
      expect(calculateStreak(sessions: []), equals(0));
    });

    test('no sessions today returns streak of 0', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-21', 3),
            ('2026-06-20', 1),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(0),
      );
    });

    test('3 consecutive days with articlesRead > 0 returns streak of 3', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 3),
            ('2026-06-21', 1),
            ('2026-06-20', 2),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(3),
      );
    });

    test('gap of one day resets streak to 0', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 1),
            ('2026-06-20', 2),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(0),
      );
    });

    test('today with articlesRead == 0 does not count as a streak day', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 0),
            ('2026-06-21', 1),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(0),
      );
    });

    test('middle day with articlesRead == 0 breaks streak', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 2),
            ('2026-06-21', 0),
            ('2026-06-20', 3),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(0),
      );
    });

    test('single today session with articlesRead > 0 returns 1', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 5),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(1),
      );
    });

    test('5 consecutive days with articlesRead > 0 returns streak of 5', () {
      expect(
        calculateStreak(
          sessions: [
            ('2026-06-22', 1),
            ('2026-06-21', 1),
            ('2026-06-20', 1),
            ('2026-06-19', 1),
            ('2026-06-18', 1),
          ],
          now: DateTime(2026, 6, 22),
        ),
        equals(5),
      );
    });
  });
}