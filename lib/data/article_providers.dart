import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../models/article.dart';
import 'article_local_store.dart';
import 'article_repository.dart';
import 'mock_article_data_source.dart';

final articleSearchQueryProvider = StateProvider<String>((ref) => '');

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((
  ref,
) {
  return const MockArticleDataSource();
});

final articleLocalStoreProvider = Provider<ArticleLocalStore>((ref) {
  return ArticleLocalStore(ref.watch(databaseProvider));
});

final wardReadyArticleRepositoryProvider = Provider<ArticleRepository>((ref) {
  return ArticleRepository(
    localStore: ref.watch(articleLocalStoreProvider),
    remoteDataSource: ref.watch(articleRemoteDataSourceProvider),
  );
});

final seedWardReadyCatalogProvider = FutureProvider<void>((ref) {
  return ref
      .watch(wardReadyArticleRepositoryProvider)
      .ensureMockCatalogSeeded();
});

final wardReadyArticlesProvider = StreamProvider<List<Article>>((ref) {
  return ref.watch(wardReadyArticleRepositoryProvider).watchArticles();
});

final articleTitlesProvider = FutureProvider<Set<String>>((ref) {
  return ref.watch(wardReadyArticleRepositoryProvider).titles();
});

final articleByTitleProvider = FutureProvider.family<Article?, String>((
  ref,
  title,
) {
  return ref.watch(wardReadyArticleRepositoryProvider).findByTitle(title);
});

final filteredArticlesProvider = Provider<AsyncValue<List<Article>>>((ref) {
  final query = ref.watch(articleSearchQueryProvider).trim().toLowerCase();
  final articles = ref.watch(wardReadyArticlesProvider);

  return articles.whenData((items) {
    if (query.isEmpty) {
      return items;
    }

return items
         .where((article) {
           final haystack = <String>[
             article.title,
             article.parentCategory,
             article.subcategory,
             article.theEssence,
             article.theLogic,
             article.thePortrait,
             article.clinicalLink,
             article.theEthiopianBedside,
             article.survivalPearl,
             article.curiosityCorner,
             article.thePlan,
             article.mnemonics,
             ...article.relatedTopics,
           ].join(' ').toLowerCase();
           return haystack.contains(query);
         })
        .toList(growable: false);
  });
});
