import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/connectivity_notifier.dart';
import '../../../core/providers/session_timeout_provider.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../../features/articles/data/article_repository.dart';
import '../../../features/auth/data/auth_service.dart';
import '../../../features/articles/data/content_update_service.dart';
import '../../../features/articles/presentation/article_search_screen.dart';
import '../../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../../features/quiz/quiz_screen.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/subscription/data/subscription_repository.dart';
import 'nav_provider.dart';
import '../../../features/home/presentation/categories_screen.dart';
import '../../../features/home/presentation/home_screen.dart';

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
    Future.microtask(
      () => ref.read(contentUpdateServiceProvider).checkForUpdates(),
    );

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
      // Account-sharing cap: refresh this device's session heartbeat
      // (updates last_seen_at) and prune over-cap / stale rows.
      try {
        await ref.read(authServiceProvider).refreshSessionHeartbeat();
      } catch (e) {
        debugPrint('Session heartbeat failed: $e');
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
    final hasContentUpdate = ref.watch(contentUpdateAvailableProvider);

    // IndexedStack has 6 children: Home, Library, Search, Saved, Quiz, Settings
    final List<Widget> screens = [
      const HomeScreen(), // 0 - Home
      const CategoriesScreen(), // 1 - Library
      const ArticleSearchScreen(), // 2
      const BookmarksScreen(), // 3
      const QuizScreen(), // 4
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
          if (index == 1) {
            ref.read(contentUpdateServiceProvider).markSeen();
          }
          ref.read(bottomNavIndexProvider.notifier).state = index;
          ref.read(sessionTimeoutProvider.notifier).resetTimer();
        },
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: hasContentUpdate
                ? const Badge(
                    isLabelVisible: true,
                    child: Icon(Icons.grid_view),
                  )
                : const Icon(Icons.grid_view),
            label: 'Library',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          const BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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