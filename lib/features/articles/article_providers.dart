import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../core/database/app_database.dart';

final highYieldModeProvider = StateProvider<bool>((ref) => false);

final subcategoryFilterProvider = StateProvider<String?>((ref) => null);

final articleByIdProvider =
    FutureProvider.autoDispose.family<ArticleLocal?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.articles)
    ..where((t) => t.id.equals(id));
  return query.get().then((articles) => articles.isNotEmpty ? articles.first : null);
});

final articleTitlesProvider = FutureProvider<Set<String>>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.select(db.articles).get();
  return rows.map((article) => article.title).toSet();
});

typedef PastExamArticleInfo = ({
  bool isHighYield,
  int examCount,
  List<int> years,
  List<String> sources,
});

final pastExamArticleInfoProvider =
    FutureProvider.autoDispose.family<PastExamArticleInfo, String>((ref, articleId) async {
  final db = ref.watch(databaseProvider);
  final rows = await db.customSelect(
    '''
    SELECT COUNT(*) as exam_count,
           GROUP_CONCAT(DISTINCT exam_year) as years,
           GROUP_CONCAT(DISTINCT exam_source) as sources
    FROM quiz_table
    WHERE article_id = ? AND source_type = 'past_exam'
    ''',
    variables: [Variable(articleId)],
  ).get();

  if (rows.isEmpty) {
    return (isHighYield: false, examCount: 0, years: <int>[], sources: <String>[]);
  }

  final row = rows.first;
  final examCount = row.read<int>('exam_count');
  final yearsStr = row.read<String?>('years');
  final sourcesStr = row.read<String?>('sources');

  final years = yearsStr != null
      ? yearsStr.split(',').map((y) => int.tryParse(y.trim())).whereType<int>().toList(growable: false)
      : <int>[];
  final sources = sourcesStr != null && sourcesStr.isNotEmpty
      ? sourcesStr.split(',').toList(growable: false)
      : <String>[];

  return (isHighYield: examCount >= 2, examCount: examCount, years: years, sources: sources);
});
