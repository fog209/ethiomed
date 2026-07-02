import 'package:flutter_riverpod/flutter_riverpod.dart';

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
