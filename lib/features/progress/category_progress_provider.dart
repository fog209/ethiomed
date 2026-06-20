import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

typedef CategoryProgress = ({int read, int total});

final categoryProgressProvider =
    FutureProvider.family<CategoryProgress, String>((ref, category) async {
      final db = ref.watch(databaseProvider);
      final read = await db.countReadArticlesByCategory(category);
      final total = await db.countArticlesByCategory(category);

      return (read: read, total: total);
    });
