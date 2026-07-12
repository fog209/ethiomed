import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_exceptions.dart';
import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/providers/sync_state_provider.dart';
import '../../../core/services/postgrest_status_helper.dart';
import '../../../main.dart' show supabaseInitializedProvider;
import '../article_providers.dart';
import '../domain/models/article.dart' as model;

const int _articlesPageSize = 20;

class ArticleRepository {
  final SupabaseClient? _supabase;
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
    // If Supabase not initialized, return local articles only (offline mode)
    if (_supabase == null) {
      debugPrint(
        'ArticleRepository: Supabase not initialized — returning cached articles.',
      );
      return _db.select(_db.articles).get();
    }
    // TODO: Implement rate limiter check - if user pulls more than 50 articles in 1 minute,
    // pause sync and show rate limit warning to prevent content scraping abuse.
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
                  category: Value(
                    article.subcategory.isNotEmpty
                        ? article.subcategory
                        : article.parentCategory,
                  ),
                  parentCategory: Value(
                    article.parentCategory.isNotEmpty
                        ? article.parentCategory
                        : null,
                  ),
                  subcategory: Value(
                    article.subcategory.isNotEmpty ? article.subcategory : null,
                  ),
                  categoryPath: Value(jsonEncode(article.category)),
                  content: Value(
                    jsonEncode(article.content ?? const <String, dynamic>{}),
                  ),
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
    String? parentCategory,
    bool highYieldOnly = false,
  }) {
    final query = _db.select(_db.articles)
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);

    if (parentCategory != null && parentCategory.trim().isNotEmpty) {
      query.where(
        (table) => table.parentCategory.equals(parentCategory.trim()),
      );
    } else if (category != null && category.trim().isNotEmpty) {
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
    String? parentCategory,
    bool highYieldOnly = false,
  }) {
    final query = _db.select(_db.articles)
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);

    if (parentCategory != null && parentCategory.trim().isNotEmpty) {
      query.where(
        (table) => table.parentCategory.equals(parentCategory.trim()),
      );
    } else if (category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category.trim()));
    }

    if (subcategory != null && subcategory.trim().isNotEmpty) {
      query.where((table) => table.subcategory.equals(subcategory.trim()));
    }

    if (highYieldOnly) {
      query.where((table) => table.isHighYield.equals(true));
    }

    debugPrint(
      'WATCH_ARTICLES_PAGED parentCategory="$parentCategory" '
      'category="$category" subcategory="$subcategory" '
      'highYieldOnly=$highYieldOnly',
    );

    return (query
          ..orderBy([(table) => OrderingTerm.asc(table.title)])
          ..limit(limit, offset: offset < 0 ? 0 : offset))
        .watch();
  }

  Future<int> countArticlesInCategory(
    String category, {
    String? subcategory,
    String? parentCategory,
    bool highYieldOnly = false,
  }) async {
    return await _db.articles
        .count(
          where: (table) {
            final parentCategoryFilter =
                parentCategory == null || parentCategory.trim().isEmpty
                ? null
                : table.parentCategory.equals(parentCategory.trim());
            final categoryFilter =
                (parentCategory == null || parentCategory.trim().isEmpty) &&
                    category.trim().isNotEmpty
                ? table.category.equals(category.trim())
                : null;
            final subcategoryFilter =
                subcategory == null || subcategory.trim().isEmpty
                ? null
                : table.subcategory.equals(subcategory.trim());
            final highYieldFilter = highYieldOnly
                ? table.isHighYield.equals(true)
                : null;

            return [
              parentCategoryFilter,
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
    String? parentCategory,
    bool highYieldOnly = false,
  }) async {
    final offset = (page - 1) * _articlesPageSize;
    final query = _db.select(_db.articles)
      ..orderBy([(table) => OrderingTerm.asc(table.title)]);

    if (parentCategory != null && parentCategory.trim().isNotEmpty) {
      query.where(
        (table) => table.parentCategory.equals(parentCategory.trim()),
      );
    } else if (category.trim().isNotEmpty) {
      query.where((table) => table.category.equals(category.trim()));
    }

    if (subcategory != null && subcategory.trim().isNotEmpty) {
      query.where((table) => table.subcategory.equals(subcategory.trim()));
    }

    if (highYieldOnly) {
      query.where((table) => table.isHighYield.equals(true));
    }

    final result =
        (query
              ..orderBy([(table) => OrderingTerm.asc(table.title)])
              ..limit(_articlesPageSize, offset: offset))
            .get();

    return result;
  }

  Future<List<ArticleLocal>> fetchRecentlyUpdatedArticles({
    int limit = 5,
  }) async {
    return (_db.select(_db.articles)
          ..orderBy([(table) => OrderingTerm.desc(table.id)])
          ..limit(limit))
        .get();
  }

  Future<List<HighYieldArticle>> getHighYieldArticles() async {
    final rows = await _db.customSelect('''
          SELECT article_id, COUNT(*) as exam_count,
                 GROUP_CONCAT(DISTINCT exam_year) as years,
                 GROUP_CONCAT(DISTINCT exam_source) as sources
          FROM quiz_table
          WHERE source_type = 'past_exam'
          GROUP BY article_id
          HAVING COUNT(*) >= 2
          ''').get();

    return rows
        .map((row) {
          final yearsStr = row.read<String?>('years');
          final years = yearsStr != null
              ? yearsStr
                    .split(',')
                    .map((y) => int.tryParse(y.trim()))
                    .whereType<int>()
                    .toList(growable: false)
              : const <int>[];

          final sourcesStr = row.read<String?>('sources');
          final sources = sourcesStr != null
              ? sourcesStr.split(',').toList(growable: false)
              : const <String>[];

          return (
            articleId: row.read<String>('article_id'),
            examCount: row.read<int>('exam_count'),
            years: years,
            sources: sources,
          );
        })
        .toList(growable: false);
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final isReady = ref.watch(supabaseInitializedProvider);
  if (!isReady) {
    // Offline mode - return repo with null supabase client
    return ArticleRepository(
      null,
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
  }
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
    this.parentCategory,
    required this.requestId,
  });

  final int limit;
  final int offset;
  final String? category;
  final String? subcategory;
  final String? parentCategory;
  final int requestId;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ArticlePageQuery &&
            other.limit == limit &&
            other.offset == offset &&
            other.category == category &&
            other.subcategory == subcategory &&
            other.parentCategory == parentCategory &&
            other.requestId == requestId;
  }

  @override
  int get hashCode => Object.hash(
    limit,
    offset,
    category,
    subcategory,
    parentCategory,
    requestId,
  );
}

final paginatedArticlesProvider =
    StreamProvider.family<List<ArticleLocal>, ArticlePageQuery>((ref, query) {
      final highYieldOnly = ref.watch(highYieldModeProvider);
      return ref
          .watch(articleRepositoryProvider)
          .watchArticlesPaged(
            category: query.category ?? '',
            subcategory: query.subcategory,
            parentCategory: query.parentCategory,
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
  const ArticleCountQuery({
    required this.category,
    this.subcategory,
    this.parentCategory,
  });

  final String category;
  final String? subcategory;
  final String? parentCategory;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ArticleCountQuery &&
            other.category == category &&
            other.subcategory == subcategory &&
            other.parentCategory == parentCategory;
  }

  @override
  int get hashCode => Object.hash(category, subcategory, parentCategory);
}

final articlesCountInCategoryAndSubcategoryProvider =
    FutureProvider.family<int, ArticleCountQuery>((ref, query) {
      final highYieldOnly = ref.watch(highYieldModeProvider);
      return ref
          .watch(articleRepositoryProvider)
          .countArticlesInCategory(
            query.category,
            subcategory: query.subcategory,
            parentCategory: query.parentCategory,
            highYieldOnly: highYieldOnly,
          );
    });

enum ArticleListStatus { initial, loading, ready, error }

class ArticleListState {
  const ArticleListState({
    this.category,
    this.subcategory,
    this.parentCategory,
    this.articles = const <ArticleLocal>[],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.status = ArticleListStatus.initial,
    this.message,
  });

  final String? category;
  final String? subcategory;
  final String? parentCategory;
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
    String? parentCategory,
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
      parentCategory: parentCategory ?? this.parentCategory,
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

typedef HighYieldArticle = ({
  String articleId,
  int examCount,
  List<int> years,
  List<String> sources,
});

const Object _unsetMessage = Object();

class ArticleListController extends StateNotifier<ArticleListState> {
  ArticleListController(this._repository) : super(const ArticleListState());

  final ArticleRepository _repository;

  Future<void> loadNextPage(
    String category, {
    String? subcategory,
    String? parentCategory,
    bool highYieldOnly = false,
  }) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    final shouldReset =
        state.category != category ||
        state.subcategory != subcategory ||
        state.parentCategory != parentCategory;
    final nextPage = shouldReset ? 1 : state.currentPage + 1;

    state = state.copyWith(
      category: category,
      subcategory: subcategory,
      parentCategory: parentCategory,
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
        parentCategory: parentCategory,
        highYieldOnly: highYieldOnly,
      );

      debugPrint(
        'ArticleListController: Loaded ${pageArticles.length} articles for category="$category", parentCategory="$parentCategory", subcategory="$subcategory"',
      );
      debugPrint(
        'ArticleListController TITLES subcategory="$subcategory": ${pageArticles.map((a) => a.title).join(' | ')}',
      );

      if (!mounted) {
        return;
      }

      final previousArticles =
          state.category == category &&
              state.subcategory == subcategory &&
              state.parentCategory == parentCategory
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
