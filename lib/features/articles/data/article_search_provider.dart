import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

const int _maxSearchResults = 50;
const Duration _searchDebounceDuration = Duration(milliseconds: 300);
const Object _unsetMessage = Object();

final articleSearchRepositoryProvider = Provider<ArticleSearchRepository>((
  ref,
) {
  return ArticleSearchRepository(ref.watch(databaseProvider));
});

final articleSearchControllerProvider =
    StateNotifierProvider.autoDispose<
      ArticleSearchController,
      ArticleSearchState
    >((ref) {
      return ArticleSearchController(
        ref.watch(articleSearchRepositoryProvider),
      );
    });

enum ArticleSearchStatus { initial, loading, ready, error }

class ArticleSearchState {
  const ArticleSearchState({
    this.query = '',
    this.category,
    this.results = const <ArticleLocal>[],
    this.count = 0,
    this.status = ArticleSearchStatus.initial,
    this.message,
  });

  final String query;
  final String? category;
  final List<ArticleLocal> results;
  final int count;
  final ArticleSearchStatus status;
  final String? message;

  bool get isLoading {
    return status == ArticleSearchStatus.loading;
  }

  bool get hasError {
    return status == ArticleSearchStatus.error;
  }

  ArticleSearchState copyWith({
    String? query,
    String? category,
    List<ArticleLocal>? results,
    int? count,
    ArticleSearchStatus? status,
    Object? message = _unsetMessage,
  }) {
    return ArticleSearchState(
      query: query ?? this.query,
      category: category ?? this.category,
      results: results ?? this.results,
      count: count ?? this.count,
      status: status ?? this.status,
      message: identical(message, _unsetMessage)
          ? this.message
          : message as String?,
    );
  }
}

class ArticleSearchController extends StateNotifier<ArticleSearchState> {
  ArticleSearchController(this._repository) : super(const ArticleSearchState());

  final ArticleSearchRepository _repository;
  Timer? _debounceTimer;

  void updateQuery(String query) {
    _debounceTimer?.cancel();
    final trimmedQuery = query.trim();

    _debounceTimer = Timer(_searchDebounceDuration, () {
      state = state.copyWith(
        query: trimmedQuery,
        results: const <ArticleLocal>[],
        count: 0,
        status: ArticleSearchStatus.loading,
        message: null,
      );
      unawaited(_runSearch(trimmedQuery, state.category));
    });
  }

  void updateCategory(String? category) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      category: category,
      results: const <ArticleLocal>[],
      count: 0,
      status: ArticleSearchStatus.loading,
      message: null,
    );
    unawaited(_runSearch(state.query, category));
  }

  Future<void> _runSearch(String query, String? category) async {
    try {
      final results = await _repository.searchArticles(
        query: query,
        category: category,
      );

      if (!mounted) {
        return;
      }

      state = state.copyWith(
        query: query,
        category: category,
        results: results,
        count: results.length,
        status: ArticleSearchStatus.ready,
        message: null,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Article search failed: $error');
      state = state.copyWith(
        query: query,
        category: category,
        results: const <ArticleLocal>[],
        count: 0,
        status: ArticleSearchStatus.error,
        message: 'Search failed. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class ArticleSearchRepository {
  ArticleSearchRepository(this._db);

  final AppDatabase _db;

  Future<List<ArticleLocal>> searchArticles({
    required String query,
    required String? category,
  }) async {
    await _ensureSearchIndex();

    final trimmedQuery = query.trim();
    final List<ArticleLocal> matches = trimmedQuery.isEmpty
        ? await _searchAllArticles()
        : await _searchWithMatch(trimmedQuery);

    final filtered = category == null
        ? matches
        : matches
              .where((article) => article.category == category)
              .toList(growable: false);

    return filtered.take(_maxSearchResults).toList(growable: false);
  }

  Future<List<ArticleLocal>> _searchAllArticles() async {
    return _db.select(_db.articles).get();
  }

  Future<List<ArticleLocal>> _searchWithMatch(String query) async {
    final ftsQuery = _toFtsQuery(query);
    if (ftsQuery.isEmpty) {
      return _searchAllArticles();
    }

    final rows = await _db
        .customSelect(
          '''
      SELECT
        a.id,
        a.title,
        a.category,
        a.content,
        a.image_url AS imageUrl,
        a.video_url AS videoUrl
      FROM article_search_fts
      JOIN articles a ON a.id = article_search_fts.article_id
      WHERE article_search_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ''',
          variables: <Variable<Object>>[
            Variable(ftsQuery),
            Variable(_maxSearchResults),
          ],
        )
        .get();

    return rows
        .map(
          (row) => ArticleLocal(
            id: row.read<String>('id'),
            title: row.read<String>('title'),
            category: row.read<String?>('category'),
            content: row.read<String?>('content'),
            imageUrl: row.read<String?>('imageUrl'),
            videoUrl: row.read<String?>('videoUrl'),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _ensureSearchIndex() async {
    try {
      await _db.customStatement('''
        CREATE VIRTUAL TABLE IF NOT EXISTS article_search_fts
        USING fts5(
          article_id UNINDEXED,
          title,
          content,
          category,
          tokenize = 'unicode61 remove_diacritics 2'
        )
        ''');

      final indexedCount = await _getIndexedCount();
      final articleCount = await _getArticleCount();
      if (indexedCount == articleCount) {
        return;
      }

      await _db.customStatement('DELETE FROM article_search_fts');
      final articles = await _db.select(_db.articles).get();

      for (final article in articles) {
        await _db.customStatement(
          '''
          INSERT INTO article_search_fts(
            article_id,
            title,
            content,
            category
          ) VALUES (?, ?, ?, ?)
          ''',
          <Object?>[
            article.id,
            article.title,
            article.content ?? '',
            article.category ?? '',
          ],
        );
      }
    } catch (error) {
      debugPrint('Unable to prepare article search index: $error');
      rethrow;
    }
  }

  Future<int> _getIndexedCount() async {
    try {
      final rows = await _db
          .customSelect('SELECT count(*) AS count FROM article_search_fts')
          .get();
      if (rows.isEmpty) {
        return 0;
      }

      return rows.first.read<int>('count');
    } catch (error) {
      debugPrint('Unable to read article search index count: $error');
      return 0;
    }
  }

  Future<int> _getArticleCount() async {
    final rows = await _db
        .customSelect('SELECT count(*) AS count FROM articles')
        .get();
    if (rows.isEmpty) {
      return 0;
    }

    return rows.first.read<int>('count');
  }

  String _toFtsQuery(String query) {
    final sanitized = query
        .replaceAll(RegExp(r'["^$()+]'), ' ')
        .replaceAll('*', ' ')
        .trim();

    if (sanitized.isEmpty) {
      return '';
    }

    final tokens = sanitized
        .split(RegExp(r'\s+'))
        .where((token) => token.trim().isNotEmpty)
        .take(8)
        .toList(growable: false);

    if (tokens.isEmpty) {
      return '';
    }

    return tokens.map((token) => '$token*').join(' OR ');
  }
}
