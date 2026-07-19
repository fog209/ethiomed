import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';

import '../../../core/database/app_database.dart';

/// A merged search hit from any of the unified content types.
enum SpotlightKind { article, flashcard, question }

class SpotlightResult {
  const SpotlightResult({
    required this.kind,
    required this.id,
    required this.title,
    required this.subtitle,
    this.article,
  });

  final SpotlightKind kind;
  final String id;
  final String title;
  final String? subtitle;
  final ArticleLocal? article;
}

class SpotlightState {
  const SpotlightState({
    this.query = '',
    this.results = const <SpotlightResult>[],
    this.status = SpotlightStatus.initial,
    this.message,
  });

  final String query;
  final List<SpotlightResult> results;
  final SpotlightStatus status;
  final String? message;

  bool get isLoading => status == SpotlightStatus.loading;
  bool get hasError => status == SpotlightStatus.error;

  SpotlightState copyWith({
    String? query,
    List<SpotlightResult>? results,
    SpotlightStatus? status,
    String? message,
  }) {
    return SpotlightState(
      query: query ?? this.query,
      results: results ?? this.results,
      status: status ?? this.status,
      message: message,
    );
  }
}

enum SpotlightStatus { initial, loading, ready, error }

const int _spotlightLimitPerType = 20;
const Duration _spotlightDebounce = Duration(milliseconds: 300);

final spotlightRepositoryProvider = Provider<SpotlightRepository>((ref) {
  return SpotlightRepository(ref.watch(databaseProvider));
});

final spotlightControllerProvider =
    StateNotifierProvider.autoDispose<SpotlightController, SpotlightState>(
  (ref) => SpotlightController(ref.watch(spotlightRepositoryProvider)),
);

class SpotlightController extends StateNotifier<SpotlightState> {
  SpotlightController(this._repository) : super(const SpotlightState());

  final SpotlightRepository _repository;
  Timer? _debounce;
  int _requestId = 0;

  void updateQuery(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    _debounce = Timer(_spotlightDebounce, () {
      final requestId = ++_requestId;
      state = state.copyWith(
        query: trimmed,
        results: const <SpotlightResult>[],
        status: SpotlightStatus.loading,
        message: null,
      );
      unawaited(_runSearch(trimmed, requestId));
    });
  }

  Future<void> _runSearch(String query, int requestId) async {
    try {
      final results = await _repository.searchAll(query);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        results: results,
        status: SpotlightStatus.ready,
        message: null,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      debugPrint('Spotlight search failed: $error');
      state = state.copyWith(
        status: SpotlightStatus.error,
        message: 'Search failed. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class SpotlightRepository {
  SpotlightRepository(this._db);

  final AppDatabase _db;

  /// Runs parallel queries against the per-content-type sources and merges
  /// them client-side into a single ranked list.
  ///
  /// Articles use the existing `article_search_fts` FTS5 table (kept exactly as
  /// it is — no synced master search table). Flashcards and questions do not
  /// yet have FTS5 tables, so they use a `LIKE` fallback; when those FTS5
  /// tables are added later, swap the fallback bodies for FTS5 `MATCH` queries
  /// and keep the merge logic below unchanged.
  Future<List<SpotlightResult>> searchAll(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const <SpotlightResult>[];

    final results = await Future.wait<Iterable<SpotlightResult>>(<
      Future<Iterable<SpotlightResult>>
    >[
      _searchArticles(trimmed),
      _searchFlashcards(trimmed),
      _searchQuestions(trimmed),
    ]);

    final merged = results.expand((r) => r).toList(growable: false);
    merged.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return merged;
  }

  Future<Iterable<SpotlightResult>> _searchArticles(String query) async {
    final ftsQuery = _toFtsQuery(query);
    if (ftsQuery.isEmpty) {
      return const <SpotlightResult>[];
    }
    try {
      final rows = await _db
          .customSelect(
            '''
            SELECT a.id, a.title, a.category
            FROM article_search_fts
            JOIN articles a ON a.id = article_search_fts.article_id
            WHERE article_search_fts MATCH ?
            ORDER BY rank
            LIMIT ?
            ''',
            variables: <Variable>[
              Variable<String>(ftsQuery),
              Variable<int>(_spotlightLimitPerType),
            ],
          )
          .get();

      // The FTS index may not exist on a fresh install — fall back to a
      // direct LIKE scan over `articles` so search still works.
      if (rows.isEmpty) {
        return _searchArticlesLike(query);
      }

      return rows.map(
        (row) => SpotlightResult(
          kind: SpotlightKind.article,
          id: row.read<String>('id'),
          title: row.read<String>('title'),
          subtitle: row.readNullable<String>('category'),
        ),
      );
    } on SqliteException catch (e) {
      if (e.message.toLowerCase().contains('no such table') ||
          e.message.toLowerCase().contains('fts5')) {
        return _searchArticlesLike(query);
      }
      rethrow;
    }
  }

  Future<Iterable<SpotlightResult>> _searchArticlesLike(String query) async {
    final pattern = '%${query.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final rows = await _db
        .customSelect(
          '''
          SELECT id, title, category FROM articles
          WHERE title LIKE ? ESCAPE '\\' OR content LIKE ? ESCAPE '\\'
          ORDER BY title ASC
          LIMIT ?
          ''',
          variables: <Variable>[
            Variable<String>(pattern),
            Variable<String>(pattern),
            Variable<int>(_spotlightLimitPerType),
          ],
        )
        .get();
    return rows.map(
      (row) => SpotlightResult(
        kind: SpotlightKind.article,
        id: row.read<String>('id'),
        title: row.read<String>('title'),
        subtitle: row.readNullable<String>('category'),
      ),
    );
  }

  Future<Iterable<SpotlightResult>> _searchFlashcards(String query) async {
    final pattern = '%${query.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final rows = await _db
        .customSelect(
          '''
          SELECT id, front_text, deck_name FROM flashcard_table
          WHERE front_text LIKE ? ESCAPE '\\' OR back_text LIKE ? ESCAPE '\\'
          ORDER BY front_text ASC
          LIMIT ?
          ''',
          variables: <Variable>[
            Variable<String>(pattern),
            Variable<String>(pattern),
            Variable<int>(_spotlightLimitPerType),
          ],
        )
        .get();
    return rows.map(
      (row) => SpotlightResult(
        kind: SpotlightKind.flashcard,
        id: row.read<int>('id').toString(),
        title: row.read<String>('front_text'),
        subtitle: row.readNullable<String>('deck_name'),
      ),
    );
  }

  Future<Iterable<SpotlightResult>> _searchQuestions(String query) async {
    final pattern = '%${query.replaceAll('%', '\\%').replaceAll('_', '\\_')}%';
    final rows = await _db
        .customSelect(
          '''
          SELECT id, stem, category FROM quiz_table
          WHERE stem LIKE ? ESCAPE '\\'
          ORDER BY stem ASC
          LIMIT ?
          ''',
          variables: <Variable>[
            Variable<String>(pattern),
            Variable<int>(_spotlightLimitPerType),
          ],
        )
        .get();
    return rows.map(
      (row) => SpotlightResult(
        kind: SpotlightKind.question,
        id: row.read<int>('id').toString(),
        title: row.read<String>('stem'),
        subtitle: row.readNullable<String>('category'),
      ),
    );
  }

  String _toFtsQuery(String query) {
    final sanitized = query
        .replaceAll(RegExp(r'["^$()+]'), ' ')
        .replaceAll('*', ' ')
        .trim();
    if (sanitized.isEmpty) return '';
    final tokens = sanitized
        .split(RegExp(r'\s+'))
        .where((t) => t.trim().isNotEmpty)
        .take(8)
        .toList(growable: false);
    if (tokens.isEmpty) return '';
    return tokens.map((t) => '$t*').join(' OR ');
  }
}
