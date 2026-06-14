import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../articles/article_model.dart';
import 'search_history_service.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Holds the raw text in the search field.
final _searchQueryProvider = StateProvider<String>((ref) => '');

/// Holds the debounced query that is actually sent to the search backend.
final _debouncedQueryProvider = StateProvider<String>((ref) => '');

/// Filters [allArticlesProvider] by [query] against title and summary.
final _searchResultsProvider =
    FutureProvider.family<List<ArticleModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return const [];

  final articles = ref.read(allArticlesProvider);
  final q = query.toLowerCase();
  return articles
      .where(
        (a) =>
            a.title.toLowerCase().contains(q) ||
            (a.summary?.toLowerCase().contains(q) ?? false),
      )
      .toList();
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  // Debounce interval — verified at 300 ms per spec.
  static const Duration _kDebounceDelay = Duration(milliseconds: 300);

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(_searchQueryProvider.notifier).state = value;

    _debounce?.cancel();
    _debounce = Timer(_kDebounceDelay, () {
      ref.read(_debouncedQueryProvider.notifier).state = value;

      if (value.trim().isNotEmpty) {
        _persistHistory(value.trim());
      }
    });
  }

  Future<void> _persistHistory(String query) async {
    final service = ref.read(searchHistoryServiceProvider);
    await service.saveSearch(query);
    // Guard against widget being unmounted before the async gap resolves.
    if (!mounted) return;
    ref.invalidate(searchHistoryProvider);
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(_searchQueryProvider.notifier).state = '';
    ref.read(_debouncedQueryProvider.notifier).state = '';
    _debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final rawQuery = ref.watch(_searchQueryProvider);
    final debouncedQuery = ref.watch(_debouncedQueryProvider);
    final resultsAsync = ref.watch(
      _searchResultsProvider(debouncedQuery.trim()),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------------
          // Search bar
          // ----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: rawQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------------------
          // Result count — only shown when query is non-empty
          // ----------------------------------------------------------------
          if (rawQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 0),
              child: resultsAsync.when(
                data: (results) => Text(
                  '${results.length} result${results.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // ----------------------------------------------------------------
          // Results / states
          // ----------------------------------------------------------------
          Expanded(
            child: rawQuery.isEmpty
                ? const _EmptyQueryState()
                : resultsAsync.when(
                    data: (results) => results.isEmpty
                        ? _ZeroResultsState(query: debouncedQuery.trim())
                        : _ResultsList(results: results),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) {
                      debugPrint('SearchScreen error: $error');
                      return Center(
                        child: Text(
                          'Something went wrong. Please try again.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Shown when the search field is empty (initial / cleared state).
class _EmptyQueryState extends StatelessWidget {
  const _EmptyQueryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Start typing to search',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.grey),
      ),
    );
  }
}

/// Shown when the debounced query returned zero results.
class _ZeroResultsState extends StatelessWidget {
  const _ZeroResultsState({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'No results for "$query". Try browsing by category',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      ),
    );
  }
}

/// Renders the list of [ArticleModel] search results.
class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});

  final List<ArticleModel> results;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final article = results[index];
        return ListTile(
          key: ValueKey(article.id),
          title: Text(article.title),
          subtitle: article.summary != null
              ? Text(
                  article.summary!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          // TODO: add onTap navigation to article detail
        );
      },
    );
  }
}
