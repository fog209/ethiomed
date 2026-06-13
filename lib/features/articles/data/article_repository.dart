import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/article.dart' as model;

const int _articlesPageSize = 20;

class ArticleRepository {
  final SupabaseClient _supabase;
  final AppDatabase _db;

  ArticleRepository(this._supabase, this._db);

  Future<void> fetchAndSyncArticles() async {
    try {
      final response = await _supabase.from('articles').select();
      final List<model.Article> remoteArticles = response
          .map((json) => model.Article.fromJson(json))
          .toList(growable: false);

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
              ),
            );
      }
    } on PostgrestException catch (error) {
      debugPrint('Sync database error: ${error.message}');
    } catch (error) {
      debugPrint('Sync Error: $error');
    }
  }

  Stream<List<ArticleLocal>> watchLocalArticles() {
    return _db.select(_db.articles).watch();
  }

  Future<List<ArticleLocal>> fetchArticlesPage({
    required String category,
    required int page,
  }) async {
    final offset = (page - 1) * _articlesPageSize;

    return (_db.select(_db.articles)
          ..where((table) => table.category.equals(category))
          ..orderBy([(table) => OrderingTerm.asc(table.title)])
          ..limit(_articlesPageSize, offset: offset))
        .get();
  }
}

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(
    Supabase.instance.client,
    ref.watch(databaseProvider),
  );
});

final allArticlesProvider = StreamProvider<List<ArticleLocal>>((ref) {
  return ref.watch(articleRepositoryProvider).watchLocalArticles();
});

enum ArticleListStatus { initial, loading, ready, error }

class ArticleListState {
  const ArticleListState({
    this.category,
    this.articles = const <ArticleLocal>[],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.status = ArticleListStatus.initial,
    this.message,
  });

  final String? category;
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
    List<ArticleLocal>? articles,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    ArticleListStatus? status,
    Object? message = _unsetMessage,
  }) {
    return ArticleListState(
      category: category ?? this.category,
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

  Future<void> loadNextPage(String category) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    final shouldReset = state.category != category;
    final nextPage = shouldReset ? 1 : state.currentPage + 1;

    state = state.copyWith(
      category: category,
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
      );

      if (!mounted) {
        return;
      }

      final previousArticles = state.category == category
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
