import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/error_exceptions.dart';

const int maxSearchResult = 50;
const Duration _searchDebounceDuration = Duration(milliseconds: 300);
const Object _unsetMessage = Object();

final articleSearchRepositoryProvider = Provider<ArticleSearchRepository>((
  ref,
) {
  return ArticleSearchRepository(ref.watch(databaseProvider));
});

class SearchResult {
  const SearchResult({required this.results, required this.totalCount});
  final List<ArticleLocal> results;
  final int totalCount;
}

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
    this.subcategory,
    this.results = const <ArticleLocal>[],
    this.count = 0,
    this.totalCount = 0,
    this.status = ArticleSearchStatus.initial,
    this.message,
  });

  final String query;
  final String? category;
  final String? subcategory;
  final List<ArticleLocal> results;
  final int count;
  final int totalCount;
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
    String? subcategory,
    List<ArticleLocal>? results,
    int? count,
    int? totalCount,
    ArticleSearchStatus? status,
    Object? message = _unsetMessage,
  }) {
    return ArticleSearchState(
      query: query ?? this.query,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      results: results ?? this.results,
      count: count ?? this.count,
      totalCount: totalCount ?? this.totalCount,
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

void updateCategory(String? category, {String? subcategory}) {
    _debounceTimer?.cancel();
    state = state.copyWith(
      category: category,
      results: const <ArticleLocal>[],
      count: 0,
      status: ArticleSearchStatus.loading,
      message: null,
    );
    unawaited(_runSearch(state.query, category, subcategory: subcategory));
  }

  Future<void> _runSearch(String query, String? category, {String? subcategory}) async {
    try {
      final searchResult = await _repository.searchArticles(
        query: query,
        category: category,
      );

      if (!mounted) {
        return;
      }

      state = state.copyWith(
        query: query,
        category: category,
        results: searchResult.results,
        count: searchResult.results.length,
        totalCount: searchResult.totalCount,
        status: ArticleSearchStatus.ready,
        message: null,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Article search failed: $error');
      final unavailable =
          error is SearchUnavailableException ||
          error.toString().toLowerCase().contains('fts5') ||
          error.toString().toLowerCase().contains('malformed');
      state = state.copyWith(
        query: query,
        category: category,
        results: const <ArticleLocal>[],
        count: 0,
        totalCount: 0,
        status: ArticleSearchStatus.error,
        message: unavailable
            ? 'Search temporarily unavailable'
            : 'Search failed. Please try again.',
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

  Future<SearchResult> searchArticles({
    required String query,
    required String? category,
    String? subcategory,
  }) async {
    await _ensureSearchIndex();

    final trimmedQuery = query.trim();
    late List<ArticleLocal> matches;
    late int totalCount;

    if (trimmedQuery.isEmpty) {
      final searchResult = await _searchAllArticles(
        category: category,
        subcategory: subcategory,
      );
      matches = searchResult.results;
      totalCount = searchResult.totalCount;
    } else {
      final searchResult = await _searchWithMatch(
        trimmedQuery,
        category: category,
        subcategory: subcategory,
      );
      matches = searchResult.results;
      totalCount = searchResult.totalCount;
    }

    return SearchResult(
      results: matches.take(maxSearchResult).toList(growable: false),
      totalCount: totalCount,
    );
  }

  Future<SearchResult> _searchAllArticles({String? category, String? subcategory}) async {
    try {
      final countFuture = _db
          .customSelect('SELECT COUNT(*) AS count FROM articles')
          .get();

      final rowsFuture = _db
          .customSelect(
            'SELECT * FROM articles LIMIT ?',
            variables: <Variable>[Variable<int>(maxSearchResult * 2)],
          )
          .get();

      final both = await Future.wait<dynamic>(<Future<dynamic>>[
        countFuture,
        rowsFuture,
      ]);

      final countRows = both[0] as List<QueryRow>;
      final rows = both[1] as List<QueryRow>;

      final totalCount = countRows.isNotEmpty
          ? countRows.first.read<int>('count')
          : 0;

      var mapped = rows
          .map(
            (row) => ArticleLocal(
              id: row.read<String>('id'),
              title: row.read<String>('title'),
              category: row.read<String?>('category'),
              subcategory: row.read<String?>('subcategory'),
              content: row.read<String?>('content'),
              imageUrl: row.read<String?>('image_url'),
              videoUrl: row.read<String?>('video_url'),
              isHighYield: row.read<bool?>('is_high_yield') ?? false,
            ),
          )
          .toList(growable: false);

      if (category != null || subcategory != null) {
        mapped = mapped
            .where((a) =>
                (category == null || a.category == category) &&
                (subcategory == null || a.subcategory == subcategory))
            .toList(growable: false);
      }

      return SearchResult(results: mapped, totalCount: totalCount);
    } catch (_) {
      final rows = await _db
          .customSelect(
            'SELECT * FROM articles LIMIT ?',
            variables: <Variable>[Variable<int>(maxSearchResult * 2)],
          )
          .get();

      var mapped = rows
          .map(
            (row) => ArticleLocal(
              id: row.read<String>('id'),
              title: row.read<String>('title'),
              category: row.read<String?>('category'),
              subcategory: row.read<String?>('subcategory'),
              content: row.read<String?>('content'),
              imageUrl: row.read<String?>('image_url'),
              videoUrl: row.read<String?>('video_url'),
              isHighYield: row.read<bool?>('is_high_yield') ?? false,
            ),
          )
          .toList(growable: false);

      if (category != null || subcategory != null) {
        mapped = mapped
            .where((a) =>
                (category == null || a.category == category) &&
                (subcategory == null || a.subcategory == subcategory))
            .toList(growable: false);
      }

      return SearchResult(results: mapped, totalCount: mapped.length);
    }
  }

  Future<SearchResult> _searchWithMatch(String query, {String? category, String? subcategory}) async {
    try {
      return await _searchWithMatchOnce(query, category: category, subcategory: subcategory);
    } on SqliteException catch (e) {
      if (_isFts5Corruption(e)) {
        await _rebuildSearchIndex();
        return _searchWithMatchOnce(query, category: category, subcategory: subcategory);
      }
      rethrow;
    }
  }

  Future<SearchResult> _searchWithMatchOnce(String query, {String? category, String? subcategory}) async {
    final ftsQuery = _toFtsQuery(query);
    if (ftsQuery.isEmpty) {
      return _searchAllArticles(category: category, subcategory: subcategory);
    }

    try {
      final countFuture = _db
          .customSelect(
            '''
        SELECT COUNT(*) AS count
        FROM article_search_fts
        WHERE article_search_fts MATCH ?
        ''',
            variables: <Variable>[Variable<String>(ftsQuery)],
          )
          .get();

      final rowsFuture = _db
          .customSelect(
            '''
      SELECT
        a.id,
        a.title,
        a.category,
        a.subcategory,
        a.content,
        a.image_url AS imageUrl,
        a.video_url AS videoUrl,
        a.is_high_yield AS isHighYield
      FROM article_search_fts
      JOIN articles a ON a.id = article_search_fts.article_id
      WHERE article_search_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ''',
            variables: <Variable>[
              Variable<String>(ftsQuery),
              Variable<int>(maxSearchResult * 2),
            ],
          )
          .get();

      final both = await Future.wait<dynamic>(<Future<dynamic>>[
        countFuture,
        rowsFuture,
      ]);

      final countRows = both[0] as List<QueryRow>;
      final rows = both[1] as List<QueryRow>;

      var results = rows
          .map(
            (row) => ArticleLocal(
              id: row.read<String>('id'),
              title: row.read<String>('title'),
              category: row.read<String?>('category'),
              subcategory: row.read<String?>('subcategory'),
              content: row.read<String?>('content'),
              imageUrl: row.read<String?>('imageUrl'),
              videoUrl: row.read<String?>('videoUrl'),
              isHighYield: row.read<bool?>('isHighYield') ?? false,
            ),
          )
          .toList(growable: false);

      if (category != null || subcategory != null) {
        results = results
            .where((a) =>
                (category == null || a.category == category) &&
                (subcategory == null || a.subcategory == subcategory))
            .toList(growable: false);
      }

      results = _applyFuzzyScore(query, results);

      final totalCount = countRows.isNotEmpty
          ? countRows.first.read<int>('count')
          : results.length;

      return SearchResult(results: results.take(maxSearchResult).toList(growable: false), totalCount: totalCount);
    } catch (_) {
      final rows = await _db
          .customSelect(
            '''
      SELECT
        a.id,
        a.title,
        a.category,
        a.subcategory,
        a.content,
        a.image_url AS imageUrl,
        a.video_url AS videoUrl,
        a.is_high_yield AS isHighYield
      FROM article_search_fts
      JOIN articles a ON a.id = article_search_fts.article_id
      WHERE article_search_fts MATCH ?
      ORDER BY rank
      LIMIT ?
      ''',
            variables: <Variable>[
              Variable<String>(ftsQuery),
              Variable<int>(maxSearchResult * 2),
            ],
          )
          .get();

      var results = rows
          .map(
            (row) => ArticleLocal(
              id: row.read<String>('id'),
              title: row.read<String>('title'),
              category: row.read<String?>('category'),
              subcategory: row.read<String?>('subcategory'),
              content: row.read<String?>('content'),
              imageUrl: row.read<String?>('imageUrl'),
              videoUrl: row.read<String?>('videoUrl'),
              isHighYield: row.read<bool?>('isHighYield') ?? false,
            ),
          )
          .toList(growable: false);

      if (category != null || subcategory != null) {
        results = results
            .where((a) =>
                (category == null || a.category == category) &&
                (subcategory == null || a.subcategory == subcategory))
            .toList(growable: false);
      }

      results = _applyFuzzyScore(query, results);

      return SearchResult(results: results.take(maxSearchResult).toList(growable: false), totalCount: results.length);
    }
  }

  Future<void> _rebuildSearchIndex() async {
    await _db.customStatement(
      'INSERT INTO article_search_fts(article_search_fts) VALUES("rebuild")',
    );
  }

  bool _isFts5Corruption(SqliteException e) {
    final message = e.message.toLowerCase();
    return message.contains('fts5') || message.contains('malformed');
  }

  Future<void> _ensureSearchIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastIndexedCount = prefs.getInt('fts_last_article_count') ?? -1;
      final currentArticleCount = await _getArticleCount();

      if (lastIndexedCount == currentArticleCount) {
        return; // Already up to date — skip expensive rebuild check
      }

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
      if (indexedCount == currentArticleCount) {
        await prefs.setInt('fts_last_article_count', currentArticleCount);
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

      await prefs.setInt('fts_last_article_count', currentArticleCount);
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

  int _levenshteinDistance(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final matrix = List.generate(
      a.length + 1,
      (i) => List.filled(b.length + 1, 0),
    );

    for (var i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  List<ArticleLocal> _applyFuzzyScore(String query, List<ArticleLocal> results) {
    final queryLower = query.toLowerCase();
    final scored = results.map((article) {
      final titleLower = article.title.toLowerCase();
      final distance = _levenshteinDistance(titleLower, queryLower);
      final startsWithMatch = titleLower.startsWith(queryLower) ? -1000 : 0;
      final containsMatch = titleLower.contains(queryLower) ? -500 : 0;
      final score = distance + startsWithMatch + containsMatch;
      return (article: article, score: score);
    }).toList();

    scored.sort((a, b) => a.score.compareTo(b.score));
    return scored.map((e) => e.article).toList();
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
