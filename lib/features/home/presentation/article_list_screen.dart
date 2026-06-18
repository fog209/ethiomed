import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../articles/data/article_repository.dart';
import '../../articles/presentation/article_detail_screen.dart';

const int _articlesPageSize = 20;

final articleOffsetProvider = StateProvider<int>((ref) => 0);
final articleRequestIdProvider = StateProvider<int>((ref) => 0);
final articleLoadedArticlesProvider = StateProvider<List<ArticleLocal>>(
  (ref) => const <ArticleLocal>[],
);
final articleHasMoreProvider = StateProvider<bool>((ref) => true);
final articleIsLoadingMoreProvider = StateProvider<bool>((ref) => false);
final articleErrorMessageProvider = StateProvider<String?>((ref) => null);
final articleCurrentCategoryProvider = StateProvider<String?>((ref) => null);

class ArticleListScreen extends ConsumerStatefulWidget {
  final String category;

  const ArticleListScreen({super.key, required this.category});

  @override
  ConsumerState<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _resetPagination();
  }

  @override
  void didUpdateWidget(covariant ArticleListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _resetPagination();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _resetPagination() {
    ref.read(articleCurrentCategoryProvider.notifier).state = widget.category;
    ref.read(articleRequestIdProvider.notifier).state =
        ref.read(articleRequestIdProvider) + 1;
    ref.read(articleOffsetProvider.notifier).state = 0;
    ref.read(articleLoadedArticlesProvider.notifier).state =
        const <ArticleLocal>[];
    ref.read(articleHasMoreProvider.notifier).state = true;
    ref.read(articleIsLoadingMoreProvider.notifier).state = false;
    ref.read(articleErrorMessageProvider.notifier).state = null;
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      _loadMoreArticles();
    }
  }

  void _loadMoreArticles() {
    final hasMore = ref.read(articleHasMoreProvider);
    final isLoadingMore = ref.read(articleIsLoadingMoreProvider);

    if (!hasMore || isLoadingMore) {
      return;
    }

    ref.read(articleIsLoadingMoreProvider.notifier).state = true;
    ref.read(articleOffsetProvider.notifier).state =
        ref.read(articleOffsetProvider) + _articlesPageSize;
  }

  List<ArticleLocal> _filterArticles(List<ArticleLocal> articles) {
    final normalizedCategory = widget.category.trim().toLowerCase();

    return articles
        .where(
          (article) =>
              (article.category?.trim().toLowerCase() ?? '') ==
              normalizedCategory,
        )
        .toList(growable: false);
  }

  Widget _buildArticleList({
    required List<ArticleLocal> articles,
    required bool isLoadingMore,
    required bool hasMore,
    String? errorMessage,
  }) {
    final filtered = _filterArticles(articles);
    final showLoadingMore = isLoadingMore && hasMore;
    final showErrorMessage = errorMessage != null && !showLoadingMore;
    final itemCount =
        filtered.length + (showLoadingMore || showErrorMessage ? 1 : 0);

    if (filtered.isEmpty && !showLoadingMore && !showErrorMessage) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: const Color(0xFF1A237E).withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No articles in ${widget.category} yet',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        if (index == filtered.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: showLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: Text(
                      errorMessage ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
          );
        }

        final article = filtered[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ArticleDetailScreen(article: article),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final offset = ref.watch(articleOffsetProvider);
    final requestId = ref.watch(articleRequestIdProvider);
    final loadedArticles = ref.watch(articleLoadedArticlesProvider);
    final isLoadingMore = ref.watch(articleIsLoadingMoreProvider);
    final hasMore = ref.watch(articleHasMoreProvider);
    final errorMessage = ref.watch(articleErrorMessageProvider);
    final paginatedProvider = paginatedArticlesProvider(
      ArticlePageQuery(
        limit: _articlesPageSize,
        offset: offset,
        category: widget.category,
        requestId: requestId,
      ),
    );
    final articlesAsync = ref.watch(paginatedProvider);

    ref.listen<AsyncValue<List<ArticleLocal>>>(paginatedProvider, (
      previous,
      next,
    ) {
      final currentCategory = ref.read(articleCurrentCategoryProvider);
      final currentRequestId = ref.read(articleRequestIdProvider);

      if (currentCategory != widget.category || currentRequestId != requestId) {
        return;
      }

      if (next.isLoading && offset > 0) {
        ref.read(articleIsLoadingMoreProvider.notifier).state = true;
        return;
      }

      if (next.hasError) {
        ref.read(articleIsLoadingMoreProvider.notifier).state = false;
        ref.read(articleErrorMessageProvider.notifier).state =
            'Unable to load articles.';
        return;
      }

      next.whenData((pageArticles) {
        final currentOffset = ref.read(articleOffsetProvider);
        final previousArticles = currentOffset == 0
            ? const <ArticleLocal>[]
            : ref.read(articleLoadedArticlesProvider);

        ref.read(articleLoadedArticlesProvider.notifier).state = <ArticleLocal>[
          ...previousArticles,
          ...pageArticles,
        ];
        ref.read(articleHasMoreProvider.notifier).state =
            pageArticles.length == _articlesPageSize;
        ref.read(articleIsLoadingMoreProvider.notifier).state = false;
        ref.read(articleErrorMessageProvider.notifier).state = null;
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: articlesAsync.when(
        data: (_) => _buildArticleList(
          articles: loadedArticles,
          isLoadingMore: isLoadingMore,
          hasMore: hasMore,
          errorMessage: errorMessage,
        ),
        loading: () {
          if (offset > 0 && loadedArticles.isNotEmpty) {
            return _buildArticleList(
              articles: loadedArticles,
              isLoadingMore: true,
              hasMore: hasMore,
              errorMessage: errorMessage,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          if (loadedArticles.isNotEmpty) {
            return _buildArticleList(
              articles: loadedArticles,
              isLoadingMore: false,
              hasMore: hasMore,
              errorMessage: 'Unable to load articles.',
            );
          }

          return Center(child: Text('Sync Error: $err'));
        },
      ),
    );
  }
}
