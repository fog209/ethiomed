import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ethiomed/features/articles/data/article_repository.dart';
import 'package:ethiomed/features/articles/presentation/article_detail_screen.dart';
import 'search_history_service.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});
  @override
  ConsumerState<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  final List<String> _categories = ['Cardiology', 'Pulmonology', 'Infectious Diseases', 'Gastroenterology', 'Neurology'];

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(allArticlesProvider);
    final history = ref.watch(searchHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Search WardReady...', hintStyle: TextStyle(color: Colors.white60), border: InputBorder.none),
          onChanged: (v) => setState(() => _query = v.toLowerCase()),
          onSubmitted: (v) => ref.read(searchHistoryProvider.notifier).saveSearch(v),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (selected) => setState(() => _selectedCategory = selected ? cat : null),
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: _query.isEmpty 
              ? (history.isEmpty 
                  ? const Center(child: Text("Search for diseases..."))
                  : ListView(children: [
                      const ListTile(title: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ...history.map((h) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(h),
                        onTap: () => setState(() { _controller.text = h; _query = h.toLowerCase(); }),
                      )),
                      TextButton(onPressed: () => ref.read(searchHistoryProvider.notifier).clearHistory(), child: const Text("Clear")),
                    ]))
              : articlesAsync.when(
                  data: (articles) {
                    final filtered = articles.where((a) {
                      final mQ = a.title.toLowerCase().contains(_query);
                      final mC = _selectedCategory == null || a.category == _selectedCategory;
                      return mQ && mC;
                    }).toList();
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (c, i) => ListTile(
                        leading: const Icon(Icons.search),
                        title: Text(filtered[i].title),
                        onTap: () {
                          ref.read(searchHistoryProvider.notifier).saveSearch(filtered[i].title);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => ArticleDetailScreen(article: filtered[i])));
                        },
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
          ),
        ],
      ),
    );
  }
}