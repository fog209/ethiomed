import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/database/app_database.dart';
import '../domain/models/article.dart' as model; // Uses 'model' prefix to avoid conflict
import 'package:drift/drift.dart';

class ArticleRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  ArticleRepository(this._supabase, this._db);

  Future<void> fetchAndSyncArticles() async {
    try {
      final response = await _supabase.from('articles').select();
      // Use model.Article to refer to your manual class
      final List<model.Article> remoteArticles = response.map((json) => model.Article.fromJson(json)).toList();

      for (var article in remoteArticles) {
        await _db.into(_db.articles).insertOnConflictUpdate(
          ArticlesCompanion.insert(
            id: article.id,
            title: article.title,
            category: Value(article.category),
            content: Value(jsonEncode(article.content)),
            imageUrl: Value(article.imageUrl),
            videoUrl: Value(article.videoUrl),
          ),
        );
      }
    } catch (e) {
      debugPrint('Sync Error: $e');
    }
  }

  // Use ArticleLocal (the name we set in Step 1)
  Stream<List<ArticleLocal>> watchLocalArticles() {
    return _db.select(_db.articles).watch();
  }
}

final articleRepositoryProvider = Provider((ref) {
  return ArticleRepository(Supabase.instance.client, ref.watch(databaseProvider));
});

final allArticlesProvider = StreamProvider<List<ArticleLocal>>((ref) {
  return ref.watch(articleRepositoryProvider).watchLocalArticles();
});