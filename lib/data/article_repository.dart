import '../models/article.dart';
import 'article_local_store.dart';
import 'mock_article_data_source.dart';

class ArticleRepository {
  ArticleRepository({
    required ArticleLocalStore localStore,
    required ArticleRemoteDataSource remoteDataSource,
  }) : _localStore = localStore,
       _remoteDataSource = remoteDataSource;

  final ArticleLocalStore _localStore;
  final ArticleRemoteDataSource _remoteDataSource;

  Stream<List<Article>> watchArticles() => _localStore.watchArticles();

  Future<List<Article>> getArticles() => _localStore.getArticles();

  Future<Article?> findByTitle(String title) => _localStore.findByTitle(title);

  Future<Set<String>> titles() => _localStore.titles();

  Future<void> ensureMockCatalogSeeded() async {
    final existing = await _localStore.getArticles();
    if (existing.isNotEmpty) {
      return;
    }
    await syncFromRemote();
  }

  Future<void> syncFromRemote() async {
    final articles = await _remoteDataSource.fetchArticles();
    await _localStore.upsertArticles(articles);
  }
}
