import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/database/app_database.dart';
import '../models/article.dart';

class ArticleLocalStore {
  ArticleLocalStore(this._db);

  final AppDatabase _db;

  Stream<List<Article>> watchArticles() {
    final query = _db.select(_db.articles)
      ..orderBy([
        (table) => OrderingTerm.asc(table.category),
        (table) => OrderingTerm.asc(table.title),
      ]);

    return query.watch().map(_decodeWardReadyRows);
  }

  Future<List<Article>> getArticles() async {
    final rows =
        await (_db.select(_db.articles)..orderBy([
              (table) => OrderingTerm.asc(table.category),
              (table) => OrderingTerm.asc(table.title),
            ]))
            .get();
    return _decodeWardReadyRows(rows);
  }

  Future<Article?> findByTitle(String title) async {
    final articles = await getArticles();
    final normalizedTitle = _normalizeTitle(title);
    for (final article in articles) {
      if (_normalizeTitle(article.title) == normalizedTitle) {
        return article;
      }
    }
    return null;
  }

  Future<Set<String>> titles() async {
    final articles = await getArticles();
    return articles.map((article) => article.title).toSet();
  }

  Future<void> upsertArticles(List<Article> articles) async {
    await _db.transaction(() async {
      for (final article in articles) {
        await _db
            .into(_db.articles)
            .insertOnConflictUpdate(
              ArticlesCompanion.insert(
                id: _storageIdForTitle(article.title),
                title: article.title,
                category: Value(article.category),
                subcategory: Value(article.subcategory),
                content: Value(jsonEncode(article.toJson())),
              ),
            );
      }
    });
  }

  List<Article> _decodeWardReadyRows(List<ArticleLocal> rows) {
    return rows.map(_decodeRow).whereType<Article>().toList(growable: false);
  }

  Article? _decodeRow(ArticleLocal row) {
    final content = row.content;
    if (content == null || content.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (!Article.wardReadyArticleKeys.every(decoded.containsKey)) {
        return null;
      }

      return Article.fromJson(decoded);
    } on FormatException {
      return null;
    }
  }

  String _storageIdForTitle(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return 'wardready-$slug';
  }

  String _normalizeTitle(String title) {
    return title.trim().toLowerCase();
  }
}
