import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/connectivity_notifier.dart';
import '../core/widgets/offline_banner.dart';
import 'nav_provider.dart';
import '../features/home/presentation/categories_screen.dart';
import '../features/articles/presentation/article_search_screen.dart';
import '../features/bookmarks/presentation/bookmarks_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/subscription/data/subscription_repository.dart';
import '../features/articles/data/article_repository.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  Timer? _subscriptionTimer;

  @override
  void initState() {
    super.initState();
    // Periodic subscription check every 30 minutes (Part 4-A)
    _subscriptionTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      if (!mounted) return;
      final isValid = await ref.read(isSubscribedProvider.future);
      if (!isValid && mounted) {
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: const Text(
              'Your subscription has expired. Renew to keep learning.',
            ),
            backgroundColor: const Color(0xFF1A237E),
            leading: const Icon(Icons.lock_clock, color: Color(0xFFF9A825)),
            actions: [
              TextButton(
                onPressed: () => context.go('/subscription'),
                child: const Text(
                  'RENEW',
                  style: TextStyle(color: Color(0xFFF9A825)),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: const Text(
                  'LATER',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscriptionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final isOnline = ref.watch(connectivityProvider);
    final serverUnreachable = ref.watch(serverUnreachableProvider);

    // IndexedStack must have exactly 6 children to match the 6 icons below
    final List<Widget> screens = [
      const CategoriesScreen(), // 0
      const ArticleSearchScreen(), // 1
      const BookmarksScreen(), // 2
      const QuizScreen(), // 3
      const ProgressScreen(), // 4
      const SettingsScreen(), // 5
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(index: selectedIndex, children: screens),
          ),
          if (serverUnreachable) _buildServerUnreachableBanner(),
          if (!isOnline) const OfflineBanner(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(bottomNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed, // Required for 5+ items
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Library',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildServerUnreachableBanner() {
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: const Text(
        'Server unreachable — showing saved content',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.orange.shade800,
      leading: const Icon(Icons.cloud_off, color: Colors.white),
      actions: [
        TextButton(
          onPressed: () => ref.invalidate(allArticlesProvider),
          child: const Text('RETRY', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
