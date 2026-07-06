import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';

enum BadgeType {
  cardiologyMaster('Cardiology Master'),
  consistentClinician('Consistent Clinician'),
  examReady('Exam Ready');

  const BadgeType(this.title);
  final String title;
}

class UserBadge {
  UserBadge({required this.type, required this.earnedAt});

  final BadgeType type;
  final DateTime earnedAt;
}

final earnedBadgesProvider = FutureProvider<List<UserBadge>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final badgesJson = prefs.getStringList('earned_badges') ?? const [];
  return badgesJson.map((s) {
    final parts = s.split('|');
    return UserBadge(
      type: BadgeType.values.firstWhere((b) => b.name == parts[0]),
      earnedAt: DateTime.parse(parts[1]),
    );
  }).toList(growable: false);
});

final achievementCheckerProvider = Provider((ref) => AchievementChecker(ref));

class AchievementChecker {
  AchievementChecker(this.ref);
  final Ref ref;

  Future<void> checkSpecialtyCompletion(String specialty) async {
    final badges = await ref.read(earnedBadgesProvider.future);
    final hasBadge = badges.any((b) => b.type == BadgeType.cardiologyMaster);
    if (!hasBadge) {
      final db = ref.read(databaseProvider);
      final rows = await db
          .customSelect(
              'SELECT COUNT(*) as total, SUM(CASE WHEN read_time_seconds > 0 THEN 1 ELSE 0 END) as read FROM articles WHERE category = ?',
              variables: [Variable(specialty)])
          .get();
      if (rows.isNotEmpty) {
        final row = rows.first;
        final total = row.read<int>('total');
        final read = row.read<int?>('read') ?? 0;
        if (total > 0 && total == read) {
          await _awardBadge(BadgeType.cardiologyMaster);
        }
      }
    }
  }

  Future<void> checkStreak(int streak) async {
    if (streak >= 7) {
      final badges = await ref.read(earnedBadgesProvider.future);
      final hasBadge = badges.any((b) => b.type == BadgeType.consistentClinician);
      if (!hasBadge) {
        await _awardBadge(BadgeType.consistentClinician);
      }
    }
  }

  Future<void> checkExamCompletion(int questionCount) async {
    if (questionCount >= 50) {
      final badges = await ref.read(earnedBadgesProvider.future);
      final hasBadge = badges.any((b) => b.type == BadgeType.examReady);
      if (!hasBadge) {
        await _awardBadge(BadgeType.examReady);
      }
    }
  }

  Future<void> _awardBadge(BadgeType type) async {
    final prefs = await SharedPreferences.getInstance();
    final badges = await ref.read(earnedBadgesProvider.future);
    final existing = badges.any((b) => b.type == type);
    if (!existing) {
      final newBadge = '${type.name}|${DateTime.now().toIso8601String()}';
      final updated = [...prefs.getStringList('earned_badges') ?? const <String>[], newBadge];
      await prefs.setStringList('earned_badges', updated);
      ref.invalidate(earnedBadgesProvider);
    }
  }
}

class TrophyCaseSection extends ConsumerWidget {
  const TrophyCaseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final badgesAsync = ref.watch(earnedBadgesProvider);

    return badgesAsync.when(
      data: (badges) {
        if (badges.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trophy Case',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: badges.map((b) => _BadgeChip(badge: b)).toList(growable: false),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const Center(child: Text('Error loading badges')),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});

  final UserBadge badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      backgroundColor: theme.colorScheme.secondaryContainer,
      label: Text(
        badge.type.title,
        style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
      ),
      avatar: const Icon(Icons.emoji_events, color: Colors.amber),
    );
  }
}