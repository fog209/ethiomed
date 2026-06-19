import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nav_provider.dart';
import '../features/home/presentation/categories_screen.dart';
import '../features/articles/presentation/article_search_screen.dart';
import '../features/bookmarks/presentation/bookmarks_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/quiz/quiz_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    // IndexedStack must have exactly 5 children to match the 5 icons below
    final List<Widget> screens = [
      const CategoriesScreen(),       // 0
      const ArticleSearchScreen(),    // 1
      const BookmarksScreen(),        // 2
      const SettingsScreen(),         // 3
      const QuizScreen(),             // 4 (The new Tab)
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed, // Required for 5+ items
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
        ],
      ),
    );
  }
}