import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/article_repository.dart';
import 'article_detail_screen.dart';

class ArticleSearchScreen extends ConsumerStatefulWidget {
  const ArticleSearchScreen({super.key});

  @override
  ConsumerState<ArticleSearchScreen> createState() => _ArticleSearchScreenState();
}

class _ArticleSearchScreenState extends ConsumerState<ArticleSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'Cardiology', 'Pulmonology', 'Infectious Diseases', 
    'Gastroenterology', 'Neurology', 'Nephrology', 
    'Endocrinology', 'Hematology', 'OB/GYN', 'Pharmacology'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(allArticlesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
        iconTheme: const IconThemeData(color: Color(0xFFFFB300)),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          cursorColor: const Color(0xFFFFB300),
          decoration: const InputDecoration(
            hintText: 'Search diseases...',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() => _query = value.toLowerCase()),
        ),
      ),
      body: Column(
        children: [
          // CATEGORY FILTER CHIPS
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFB300),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // SEARCH RESULTS
          Expanded(
            child: articlesAsync.when(
              data: (articles) {
                final filtered = articles.where((a) {
                  final matchesQuery = a.title.toLowerCase().contains(_query);
                  final matchesCategory = _selectedCategory == null || a.category == _selectedCategory;
                  return matchesQuery && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No matching articles found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final article = filtered[index];
                    return ListTile(
                      leading: const Icon(Icons.search, color: Color(0xFF1A237E)),
                      title: Text(article.title),
                      subtitle: Text(article.category ?? ''),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}