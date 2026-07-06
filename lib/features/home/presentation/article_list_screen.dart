import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/empty_state.dart';
import '../../articles/article_providers.dart';
import '../../articles/data/article_repository.dart';

const int _articlesPageSize = 20;

final articleOffsetProvider = StateProvider<int>((ref) => 0);
final articleRequestIdProvider = StateProvider<int>((ref) => 0);
final articleLoadedArticlesProvider = StateProvider<List<ArticleLocal>>(
  (ref) => const <ArticleLocal>[],
);
final articleHasMoreProvider = StateProvider<bool>((ref) => true);
final articleIsLoadingMoreProvider = StateProvider<bool>((ref) => false);
final articleCurrentCategoryProvider = StateProvider<String?>((ref) => null);
const Map<String, List<String>> subcategoriesByCategory = {
  'Internal Medicine': ['Cardiology', 'Neurology', 'Nephrology'],
  'Pediatrics': ['Neonatology', 'Nutrition', 'Emergency', 'Infectious'],
};

class ArticleListScreen extends ConsumerStatefulWidget {
  final String category;
  final String? parentCategory;

  const ArticleListScreen({super.key, required this.category, this.parentCategory});

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
    Future.microtask(() {
      if (mounted) _resetPagination();
    });
  }

  @override
  void didUpdateWidget(covariant ArticleListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category || oldWidget.parentCategory != widget.parentCategory) {
      _resetPagination();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _runAfterBuild(VoidCallback callback) {
    Future.microtask(callback);
  }

  void _resetPagination({bool resetSubcategory = true}) {
    ref.read(articleCurrentCategoryProvider.notifier).state = widget.category;
    if (resetSubcategory) {
      ref.read(subcategoryFilterProvider.notifier).state = null;
    }
    ref.read(articleRequestIdProvider.notifier).state =
        ref.read(articleRequestIdProvider) + 1;
    ref.read(articleOffsetProvider.notifier).state = 0;
    ref.read(articleLoadedArticlesProvider.notifier).state =
        const <ArticleLocal>[];
    ref.read(articleHasMoreProvider.notifier).state = true;
    ref.read(articleIsLoadingMoreProvider.notifier).state = false;
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.8) {
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
    final selectedSubcategory = ref.read(subcategoryFilterProvider);
    debugPrint('ArticleListScreen: Loading articles for category="${widget.category}", parentCategory="${widget.parentCategory}"');
    ref
        .read(articleListControllerProvider.notifier)
        .loadNextPage(
          widget.parentCategory ?? widget.category,
          subcategory: selectedSubcategory,
          parentCategory: widget.parentCategory,
          highYieldOnly: ref.read(highYieldModeProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    final highYieldMode = ref.watch(highYieldModeProvider);
    final offset = ref.watch(articleOffsetProvider);
    final requestId = ref.watch(articleRequestIdProvider);
    final loadedArticles = ref.watch(articleLoadedArticlesProvider);
    final isLoadingMore = ref.watch(articleIsLoadingMoreProvider);
    final hasMore = ref.watch(articleHasMoreProvider);
    final subcategories = subcategoriesByCategory[widget.category];
    final selectedSubcategory = ref.watch(subcategoryFilterProvider);
    final totalArticlesAsync = ref.watch(
      articlesCountInCategoryAndSubcategoryProvider(
        ArticleCountQuery(
          category: widget.parentCategory ?? widget.category,
          subcategory: selectedSubcategory,
          parentCategory: widget.parentCategory,
        ),
      ),
    );
    final totalArticles = totalArticlesAsync.valueOrNull;
    final hasMoreFromCount = totalArticles == null
        ? hasMore
        : loadedArticles.length < totalArticles;
    final paginatedProvider = paginatedArticlesProvider(
      ArticlePageQuery(
        limit: _articlesPageSize,
        offset: offset,
        category: widget.parentCategory ?? widget.category,
        subcategory: selectedSubcategory,
        parentCategory: widget.parentCategory,
        requestId: requestId,
      ),
    );
    final articlesAsync = ref.watch(paginatedProvider);
    final articleListWidget = articlesAsync.when(
      data: (_) => _buildArticleList(
        articles: loadedArticles,
        isLoadingMore: isLoadingMore,
        hasMore: hasMoreFromCount,
      ),
      loading: () {
        if (offset > 0 && loadedArticles.isNotEmpty) {
          return _buildArticleList(
            articles: loadedArticles,
            isLoadingMore: true,
            hasMore: hasMoreFromCount,
          );
        }

        return _buildShimmerArticleList();
      },
      error: (err, stack) {
        if (loadedArticles.isNotEmpty) {
          return _buildArticleList(
            articles: loadedArticles,
            isLoadingMore: false,
            hasMore: hasMoreFromCount,
            errorMessage: 'Unable to load articles.',
          );
        }

        return Center(child: Text('Error: $err'));
      },
    );

    _listenToPaginationChanges(context, paginatedProvider, requestId, offset);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            tooltip: 'High-Yield Mode',
            color: highYieldMode
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () {
              ref.read(highYieldModeProvider.notifier).state = !highYieldMode;
            },
            icon: Icon(highYieldMode ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: subcategories == null || subcategories.isEmpty
          ? articleListWidget
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      ChoiceChip(
                          label: const Text('All'),
                          selected: selectedSubcategory == null,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          labelStyle: TextStyle(
                            color: selectedSubcategory == null
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.white,
                          ),
                          onSelected: (_) {
                            ref.read(subcategoryFilterProvider.notifier).state =
                                null;
                          },
                        ),
                      const SizedBox(width: 8),
                      ...subcategories.map((subcategory) {
                        final isSelected = selectedSubcategory == subcategory;
                        final theme = Theme.of(context);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(subcategory),
                            selected: isSelected,
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: theme.colorScheme.surface,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : Colors.white,
                            ),
                            onSelected: (_) {
                              ref
                                      .read(subcategoryFilterProvider.notifier)
                                      .state =
                                  subcategory;
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: articleListWidget,
                ),
              ],
            ),
    );
  }

  void _listenToPaginationChanges(
    BuildContext context,
    ProviderListenable<AsyncValue<List<ArticleLocal>>> provider,
    int requestId,
    int offset,
  ) {
    ref.listen<bool>(highYieldModeProvider, (previous, next) {
      if (previous != next) {
        _resetPagination();
      }
    });

    ref.listen<String?>(subcategoryFilterProvider, (previous, next) {
      if (previous != next) {
        _resetPagination(resetSubcategory: false);
      }
    });

    ref.listen<AsyncValue<List<ArticleLocal>>>(provider, (previous, next) {
      final currentCategory = ref.read(articleCurrentCategoryProvider);
      final currentRequestId = ref.read(articleRequestIdProvider);
      final requestedOffset = ref.read(articleOffsetProvider);

      if (currentCategory != widget.category || currentRequestId != requestId) {
        return;
      }

      if (next.isLoading && offset > 0) {
        _runAfterBuild(() {
          ref.read(articleIsLoadingMoreProvider.notifier).state = true;
        });
        return;
      }

      if (next.hasError) {
        _runAfterBuild(() {
          if (!mounted) {
            return;
          }
          ref.read(articleOffsetProvider.notifier).state = requestedOffset;
          ref.read(articleIsLoadingMoreProvider.notifier).state = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not load more. Try again.')),
          );
        });
        return;
      }

      next.whenData((pageArticles) {
        final currentOffset = ref.read(articleOffsetProvider);
        final previousArticles = currentOffset == 0
            ? const <ArticleLocal>[]
            : ref.read(articleLoadedArticlesProvider);
        final loadedCount = currentOffset == 0
            ? pageArticles.length
            : previousArticles.length + pageArticles.length;
        final totalArticles = ref
            .read(
              articlesCountInCategoryAndSubcategoryProvider(
                ArticleCountQuery(
                  category: widget.parentCategory ?? widget.category,
                  subcategory: ref.read(subcategoryFilterProvider),
                  parentCategory: widget.parentCategory,
                ),
              ),
            )
            .valueOrNull;

        _runAfterBuild(() {
          ref.read(articleLoadedArticlesProvider.notifier).state =
              <ArticleLocal>[...previousArticles, ...pageArticles];
          ref.read(articleOffsetProvider.notifier).state =
              currentOffset + _articlesPageSize;
          ref
              .read(articleHasMoreProvider.notifier)
              .state = totalArticles == null
              ? pageArticles.length == _articlesPageSize
              : loadedCount < totalArticles;
          ref.read(articleIsLoadingMoreProvider.notifier).state = false;
        });
      });
    });
  }

  Widget _buildArticleList({
    required List<ArticleLocal> articles,
    required bool isLoadingMore,
    required bool hasMore,
    String? errorMessage,
  }) {
    final showLoadingMore = isLoadingMore && hasMore;
    final showErrorMessage = errorMessage != null && !showLoadingMore;
    final itemCount =
        articles.length + (showLoadingMore || showErrorMessage ? 1 : 0);

    if (articles.isEmpty && !showLoadingMore && !showErrorMessage) {
      return const EmptyState(
        icon: Icons.article_outlined,
        title: 'No articles yet',
        subtitle: 'Articles will appear here once synced',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: showLoadingMore
                ? _buildShimmerArticleTile()
                : Center(
                    child: Text(
                      errorMessage ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
          );
        }

        final article = articles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Row(
              children: [
                if (article.isHighYield)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                Expanded(
                  child: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '~${article.estimatedReadMinutes} min',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/article-detail', extra: article),
          ),
        );
      },
    );
  }

  Widget _buildShimmerArticleList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => _buildShimmerArticleTile(),
    );
  }

  Widget _buildShimmerArticleTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Container(height: 12, width: 180, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}