import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/connectivity_notifier.dart';
import '../core/providers/session_timeout_provider.dart';
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
  bool _isListeningForLogout = false;

  @override
  void initState() {
    super.initState();
    // Initialize session timeout
    ref.read(sessionTimeoutProvider.notifier).resetTimer();

    // Periodic subscription check every 30 minutes (Part 4-A)
    _subscriptionTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      if (!mounted) return;
      final isValid = await ref.read(isSubscribedProvider.future);
      if (!isValid && mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showMaterialBanner(
          MaterialBanner(
            content: Text(
              'Your subscription has expired. Renew to keep learning.',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            backgroundColor: theme.colorScheme.surface,
            leading: Icon(Icons.lock_clock, color: theme.colorScheme.primary),
            actions: [
              TextButton(
                onPressed: () => context.go('/subscription'),
                child: Text(
                  'RENEW',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
              TextButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                child: Text(
                  'LATER',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          ref.read(sessionTimeoutProvider.notifier).resetTimer();
        },
        onPanDown: (_) {
          ref.read(sessionTimeoutProvider.notifier).resetTimer();
        },
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(index: selectedIndex, children: screens),
            ),
            if (serverUnreachable) _buildServerUnreachableBanner(),
            if (!isOnline) const OfflineBanner(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          ref.read(sessionTimeoutProvider.notifier).resetTimer();
        },
        type: BottomNavigationBarType.fixed, // Required for 5+ items
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
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