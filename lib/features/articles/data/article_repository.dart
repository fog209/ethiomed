import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_exceptions.dart';
import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/providers/sync_state_provider.dart';
import '../../../core/services/postgrest_status_helper.dart';
import '../article_providers.dart';
import '../domain/models/article.dart' as model;

const int _articlesPageSize = 20;

class ArticleRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  final VoidCallback _onServerUnreachable;
  final VoidCallback _onRateLimited;
  final VoidCallback _onSyncIncomplete;
  final VoidCallback _onDiskFull;
  final VoidCallback _onSuccessfulSync;

  ArticleRepository(
    this._supabase,
    this._db,
    this._onServerUnreachable,
    this._onRateLimited,
    this._onSyncIncomplete,
    this._onDiskFull,
    this._onSuccessfulSync,
  );

Future<List<ArticleLocal>> fetchAndSyncArticles() async {
    try {
      final response = await _supabase
          .from('articles')
          .select('*, is_high_yield');
      final List<model.Article> remoteArticles = response
          .map((json) => model.Article.fromJson(json))
          .toList(growable: false);

      await _db.transaction(() async {
         for (final article in remoteArticles) {
           await _db
               .into(_db.articles)
               .insertOnConflictUpdate(
                 ArticlesCompanion.insert(
                   id: article.id,
                   title: article.title,
                   category: Value(article.category),
                   content: Value(jsonEncode(article.content)),
                   imageUrl: Value(article.imageUrl),
                   videoUrl: Value(article.videoUrl),
                   isHighYield: Value(article.isHighYield),
                 ),
               );
         }
       });

       _onSuccessfulSync();
    } on PostgrestException catch (e) {
      final status = postgrestStatus(e);
      if (status == 401) {
        throw const SupabaseSessionExpiredException();
      }
      if (status == 403) {
        debugPrint('RLS rejection on articles: ${e.message}');
        return _db.select(_db.articles).get();
      }
      if (status == 429) {
        _onRateLimited();
        return _db.select(_db.articles).get();
      }
      if (status == 503 || status == 504) {
        _onServerUnreachable();
        return _db.select(_db.articles).get();
      }

      debugPrint('Sync error: ${e.message}');
      throw AppException(e.message);
    } on SocketException catch (e) {
      _onServerUnreachable();
      debugPrint('Sync error: $e');
      throw AppException('Sync failed. Cached data shown.');
    } on SqliteException catch (e) {
      if (_isDiskFull(e)) {
        _onDiskFull();
        throw const DiskFullException();
      }
      rethrow;
    } catch (e) {
      if (e is DiskFullException) {
        rethrow;
      }
      _onSyncIncomplete();
      debugPrint('Sync error: $e');
      throw AppException('Sync failed. Cached data shown.');
    }

    return _db.select(_db.articles).get();
  }

  bool _isDiskFull(SqliteException e) {
    final message = e.message.toLowerCase();
    return message.contains('disk') ||
        message.contains('full') ||
        message.contains('sqlite_full');
  }

  Future<List<ArticleLocal>> syncInBackground() => fetchAndSyncArticles();

  Stream<List<ArticleLocal>> watchLocalArticles({
    int limit = 0,
    int offset = 0,
    String? category,
    String? subcategory,
    bool highYieldOnly = false,
  }) {
    final query = _db.select(_db.articles)
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);

    if (category != null && category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category.trim()));
    }

    if (subcategory != null && subcategory.trim().isNotEmpty) {
      query.where((table) => table.subcategory.equals(subcategory.trim()));
    }

    if (highYieldOnly) {
      query.where((table) => table.isHighYield.equals(true));
    }

    return (query
          ..orderBy([(table) => OrderingTerm.asc(table.title)])
          ..limit(
            limit > 0 ? limit : _articlesPageSize,
            offset: offset < 0 ? 0 : offset,
          ))
        .watch();
  }

  Stream<List<ArticleLocal>> watchArticlesPaged({
    required String category,
    required int limit,
    required int offset,
    String? subcategory,
    bool highYieldOnly = false,
  }) {
    final query = _db.select(_db.articles)
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);

    if (category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category.trim()));
    }

    if (subcategory != null && subcategory.trim().isNotEmpty) {
      query.where((table) => table.subcategory.equals(subcategory.trim()));
    }

    if (highYieldOnly) {
      query.where((table) => table.isHighYield.equals(true));
    }

    return (query
          ..orderBy([(table) => OrderingTerm.asc(table.title)])
          ..limit(limit, offset: offset < 0 ? 0 : offset))
        .watch();
  }

  Future<int> countArticlesInCategory(
    String category, {
    String? subcategory,
    bool highYieldOnly = false,
  }) async {
    return await _db.articles
        .count(
          where: (table) {
            final categoryFilter = table.category.equals(category.trim());
            final subcategoryFilter =
                subcategory == null || subcategory.trim().isEmpty
                ? null
                : table.subcategory.equals(subcategory.trim());
            final highYieldFilter = highYieldOnly
                ? table.isHighYield.equals(true)
                : null;

            return [
              categoryFilter,
              subcategoryFilter,
              highYieldFilter,
            ].whereType<Expression<bool>>().reduce((a, b) => a & b);
          },
        )
        .getSingle();
  }

  Future<List<ArticleLocal>> fetchArticlesPage({
    required String category,
    required int page,
    String? subcategory,
    bool highYieldOnly = false,
  }) async {
    final offset = (page - 1) * _articlesPageSize;
    final query = _db.select(_db.articles)
      ..where((table) => table.category.equals(category));

    if (subcategory != null && subcategory.trim().isNotEmpty) {
      query.where((table) => table.subcategory.equals(subcategory.trim()));
    }

    if (highYieldOnly) {
      query.where((table) => table.isHighYield.equals(true));
    }

    final result = (query
          ..orderBy([(table) => OrderingTerm.asc(table.title)])
          ..limit(_articlesPageSize, offset: offset))
        .get();

    return result;
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(
    Supabase.instance.client,
    ref.watch(databaseProvider),
    () {
      ref.read(connectivityProvider.notifier).markOffline();
      ref.read(syncStateProvider.notifier).setServerUnreachable();
      ref.read(serverUnreachableProvider.notifier).markUnreachable();
    },
    () => ref.read(syncStateProvider.notifier).setRateLimited(),
    () => ref.read(syncStateProvider.notifier).markSyncIncomplete(),
    () => ref.read(syncStateProvider.notifier).setDiskFull(),
    () {
      ref.read(syncStateProvider.notifier).setSuccessfulSync();
      ref.read(serverUnreachableProvider.notifier).markReachable();
    },
  );
});

final allArticlesProvider = StreamProvider<List<ArticleLocal>>((ref) {
  final highYieldOnly = ref.watch(highYieldModeProvider);
  return ref
      .watch(articleRepositoryProvider)
      .watchLocalArticles(highYieldOnly: highYieldOnly);
});

final articlesProvider = allArticlesProvider;

class ArticlePageQuery {
  const ArticlePageQuery({
    required this.limit,
    required this.offset,
    this.category,
    this.subcategory,
    required this.requestId,
  });

  final int limit;
  final int offset;
  final String? category;
  final String? subcategory;
  final int requestId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ArticlePageQuery &&
            other.limit == limit &&
            other.offset == offset &&
            other.category == category &&
            other.subcategory == subcategory &&
            other.requestId == requestId;
  }

  @override
  int get hashCode =>
      Object.hash(limit, offset, category, subcategory, requestId);
}

final paginatedArticlesProvider =
    StreamProvider.family<List<ArticleLocal>, ArticlePageQuery>((ref, query) {
      final highYieldOnly = ref.watch(highYieldModeProvider);
      return ref
          .watch(articleRepositoryProvider)
          .watchArticlesPaged(
            category: query.category ?? '',
            subcategory: query.subcategory,
            limit: query.limit,
            offset: query.offset,
            highYieldOnly: highYieldOnly,
          );
    });

final articlesCountInCategoryProvider = FutureProvider.family<int, String>((
  ref,
  category,
) {
  final highYieldOnly = ref.watch(highYieldModeProvider);
  return ref
      .watch(articleRepositoryProvider)
      .countArticlesInCategory(category, highYieldOnly: highYieldOnly);
});

class ArticleCountQuery {
  const ArticleCountQuery({required this.category, this.subcategory});

  final String category;
  final String? subcategory;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ArticleCountQuery &&
            other.category == category &&
            other.subcategory == subcategory;
  }

  @override
  int get hashCode => Object.hash(category, subcategory);
}

final articlesCountInCategoryAndSubcategoryProvider =
    FutureProvider.family<int, ArticleCountQuery>((ref, query) {
      final highYieldOnly = ref.watch(highYieldModeProvider);
      return ref
          .watch(articleRepositoryProvider)
          .countArticlesInCategory(
            query.category,
            subcategory: query.subcategory,
            highYieldOnly: highYieldOnly,
          );
    });

enum ArticleListStatus { initial, loading, ready, error }

class ArticleListState {
  const ArticleListState({
    this.category,
    this.subcategory,
    this.articles = const <ArticleLocal>[],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.status = ArticleListStatus.initial,
    this.message,
  });

  final String? category;
  final String? subcategory;
  final List<ArticleLocal> articles;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final ArticleListStatus status;
  final String? message;

  bool get hasError {
    return status == ArticleListStatus.error;
  }

  ArticleListState copyWith({
    String? category,
    String? subcategory,
    List<ArticleLocal>? articles,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    ArticleListStatus? status,
    Object? message = _unsetMessage,
  }) {
    return ArticleListState(
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      articles: articles ?? this.articles,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      message: identical(message, _unsetMessage)
          ? this.message
          : message as String?,
    );
  }
}

const Object _unsetMessage = Object();

class ArticleListController extends StateNotifier<ArticleListState> {
  ArticleListController(this._repository) : super(const ArticleListState());

  final ArticleRepository _repository;

  Future<void> loadNextPage(
    String category, {
    String? subcategory,
    bool highYieldOnly = false,
  }) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    final shouldReset =
        state.category != category || state.subcategory != subcategory;
    final nextPage = shouldReset ? 1 : state.currentPage + 1;

    state = state.copyWith(
      category: category,
      subcategory: subcategory,
      currentPage: nextPage,
      isLoadingMore: true,
      status: ArticleListStatus.loading,
      articles: shouldReset ? const <ArticleLocal>[] : state.articles,
      hasMore: shouldReset ? true : state.hasMore,
      message: null,
    );

    try {
      final pageArticles = await _repository.fetchArticlesPage(
        category: category,
        page: nextPage,
        subcategory: subcategory,
        highYieldOnly: highYieldOnly,
      );

      if (!mounted) {
        return;
      }

      final previousArticles =
          state.category == category && state.subcategory == subcategory
          ? state.articles
          : const <ArticleLocal>[];
      final combinedArticles = <ArticleLocal>[
        ...previousArticles,
        ...pageArticles,
      ];

      state = state.copyWith(
        articles: combinedArticles,
        currentPage: nextPage,
        isLoadingMore: false,
        hasMore: pageArticles.length == _articlesPageSize,
        status: ArticleListStatus.ready,
        message: null,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Unable to load article page: $error');
      state = state.copyWith(
        isLoadingMore: false,
        status: ArticleListStatus.error,
        message: 'Unable to load articles.',
      );
    }
  }
}

final articleListControllerProvider =
    StateNotifierProvider<ArticleListController, ArticleListState>((ref) {
      return ArticleListController(ref.watch(articleRepositoryProvider));
    });
