import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nav_provider.dart';
import '../features/home/presentation/categories_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/bookmarks/presentation/bookmarks_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> screens = [
      const CategoriesScreen(), // Tab 0: Specialty Grid
      const ArticleSearchScreen(), // Tab 1: Search
      const BookmarksScreen(), // Tab 2: Saved Articles
      const SettingsScreen(), // Tab 3: Account/Logout
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E), // Navy
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Specialties',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
