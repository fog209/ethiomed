import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../articles/data/article_repository.dart';
import '../../articles/presentation/article_detail_screen.dart';

class ArticleListScreen extends ConsumerStatefulWidget {
  final String category;

  const ArticleListScreen({super.key, required this.category});

  @override
  ConsumerState<ArticleListScreen> createState() {
    return _ArticleListScreenState();
  }
}

class _ArticleListScreenState extends ConsumerState<ArticleListScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(articleListControllerProvider.notifier)
          .loadNextPage(widget.category);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0 && currentScroll >= maxScroll * 0.9) {
      ref
          .read(articleListControllerProvider.notifier)
          .loadNextPage(widget.category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(articleListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: _buildBody(listState),
    );
  }

  Widget _buildBody(ArticleListState listState) {
    if (listState.hasError) {
      return Center(
        child: Text(listState.message ?? 'Error loading articles.'),
      );
    }

    if (listState.articles.isEmpty && listState.isLoadingMore) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listState.articles.isEmpty) {
      return const Center(child: Text('No articles in this section yet.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount:
          listState.articles.length +
          (listState.isLoadingMore || !listState.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= listState.articles.length) {
          return _buildBottomStatus(listState);
        }

        final article = listState.articles[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(article: article),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomStatus(ArticleListState listState) {
    if (listState.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Center(child: Text('No more articles')),
    );
  }
}
