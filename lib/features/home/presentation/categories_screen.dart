import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../articles/data/article_repository.dart';
import 'article_list_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Cardiology', 'icon': Icons.favorite},
    {'name': 'Pulmonology', 'icon': Icons.air},
    {'name': 'Infectious Diseases', 'icon': Icons.bug_report},
    {'name': 'Gastroenterology', 'icon': Icons.restaurant},
    {'name': 'Neurology', 'icon': Icons.psychology},
    {'name': 'Nephrology', 'icon': Icons.water_drop},
    {'name': 'Endocrinology', 'icon': Icons.monitor_weight},
    {'name': 'Hematology', 'icon': Icons.bloodtype},
    {'name': 'OB/GYN', 'icon': Icons.pregnant_woman},
    {'name': 'Pharmacology', 'icon': Icons.medication},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WardReady Specialties'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: const Color(0xFFFFB300),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleListScreen(category: cat['name']),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'], size: 40, color: const Color(0xFF1A237E)),
                  const SizedBox(height: 10),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // ADDING THE BUTTON BACK HERE:
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFFB300),
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Syncing with WardReady Cloud..."), duration: Duration(seconds: 1)),
          );
          await ref.read(articleRepositoryProvider).fetchAndSyncArticles();
        },
        child: const Icon(Icons.sync, color: Color(0xFF1A237E)),
      ),
    );
  }
}