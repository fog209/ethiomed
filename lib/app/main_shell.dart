import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/providers/session_timeout_provider.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../features/articles/data/article_repository.dart';
import '../../../features/articles/presentation/article_search_screen.dart';
import '../../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../../features/quiz/quiz_screen.dart';
import '../../../features/progress/progress_screen.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/subscription/data/subscription_repository.dart';
import 'nav_provider.dart';
import '../../../features/home/presentation/categories_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  Timer? _subscriptionTimer;
  bool _isListeningForLogout = false;

  @override
  void initState() {
    super.initState();
    ref.read(sessionTimeoutProvider.notifier).resetTimer();

    // Periodic subscription check every 30 minutes (Part 4-A)
    _subscriptionTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      if (!mounted) return;
      try {
        final isValid = await ref.read(subscriptionRepositoryProvider)
            .checkSubscriptionStatus();
        if (!isValid && mounted) {
          context.go('/subscription');
        }
      } catch (e) {
        debugPrint('Periodic subscription check failed: $e');
        // Never throw - just log and skip
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
    if (!_isListeningForLogout) {
      _isListeningForLogout = true;
      ref.listen<bool>(sessionTimeoutProvider, (_, shouldLogout) {
        if (shouldLogout && context.mounted) {
          context.go('/login');
          ref.read(sessionTimeoutProvider.notifier).consumeLogout();
        }
      });
    }

    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final isOnline = ref.watch(connectivityProvider);
    final serverUnreachable = ref.watch(serverUnreachableProvider);

    // IndexedStack has 6 children: Library, Search, Saved, Quiz, Progress, Settings
    final List<Widget> screens = [
      const CategoriesScreen(), // 0 - Library
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
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          ref.read(sessionTimeoutProvider.notifier).resetTimer();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Library'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildServerUnreachableBanner() {
    final theme = Theme.of(context);
    return MaterialBanner(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: Text(
        'Server unreachable — showing saved content',
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
      backgroundColor: theme.colorScheme.errorContainer,
      leading: Icon(Icons.cloud_off, color: theme.colorScheme.onErrorContainer),
      actions: [
        TextButton(
          onPressed: () => ref.invalidate(allArticlesProvider),
          child: Text('RETRY', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
        ),
      ],
    );
  }
}