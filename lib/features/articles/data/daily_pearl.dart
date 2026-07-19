import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../models/article_model.dart';

/// Section keys that carry pearl-style, self-contained insight worth
/// surfacing as a daily card. Limited to keys that actually exist in the
/// live article schema — no invented/guessed section names.
const Set<String> _pearlSectionKeys = <String>{
  'clinicalPearls',
  'mnemonics',
};

/// A single candidate pearl: the source article plus one pearl-style section.
class PearlCandidate {
  const PearlCandidate({
    required this.articleId,
    required this.articleTitle,
    required this.sectionKey,
    required this.body,
  });

  final String articleId;
  final String articleTitle;
  final String sectionKey;
  final String body;
}

/// A sampled daily pearl, or null when no eligible content exists.
class DailyPearl {
  const DailyPearl({
    required this.articleId,
    required this.articleTitle,
    required this.sectionKey,
    required this.body,
  });

  final String articleId;
  final String articleTitle;
  final String sectionKey;
  final String body;

  /// First ~180 chars for the compact home-card preview.
  String get preview {
    final trimmed = body.trim();
    if (trimmed.length <= 180) return trimmed;
    return '${trimmed.substring(0, 180).trimRight()}…';
  }
}

/// Pure, deterministic selection: picks one pearl for [day] from [candidates]
/// so the same calendar day always yields the same pearl. Selection is seeded
/// by the day index (days since epoch) modulo the candidate count, not a
/// random draw — so reopening the app on the same day never changes it.
DailyPearl? pickDailyPearl(List<PearlCandidate> candidates, DateTime day) {
  if (candidates.isEmpty) return null;
  final epoch = DateTime(1970, 1, 1);
  final dayNumber = day.difference(epoch).inDays;
  final index = dayNumber % candidates.length;
  final chosen = candidates[index];
  return DailyPearl(
    articleId: chosen.articleId,
    articleTitle: chosen.articleTitle,
    sectionKey: chosen.sectionKey,
    body: chosen.body,
  );
}

/// Collects every pearl-style section across all local articles.
List<PearlCandidate> _collectPearls(List<ArticleLocal> articles) {
  final pearls = <PearlCandidate>[];
  for (final article in articles) {
    if (article.content == null || article.content!.isEmpty) continue;
    final content = ArticleContent.fromJson(
      jsonDecode(article.content!) as Map<String, dynamic>,
    );
    for (final section in content.sections) {
      if (_pearlSectionKeys.contains(section.key) &&
          section.body.trim().isNotEmpty) {
        pearls.add(
          PearlCandidate(
            articleId: article.id,
            articleTitle: article.title,
            sectionKey: section.key,
            body: section.body,
          ),
        );
      }
    }
  }
  return pearls;
}

/// In-app "Daily Pearl" — one sampled pearl from local article sections,
/// stable for the whole calendar day and changing the next day. Returns null
/// when there is no eligible content (callers should hide the card).
final dailyPearlProvider = FutureProvider<DailyPearl?>((ref) async {
  final db = ref.watch(databaseProvider);
  final articles = await db.select(db.articles).get();
  final candidates = _collectPearls(articles);
  return pickDailyPearl(candidates, DateTime.now());
});
