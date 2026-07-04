import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/env.dart';
import 'app/main_shell.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/screens/database_recovery_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/presentation/admin_dashboard_screen.dart';
import 'features/articles/presentation/article_detail_screen.dart';
import 'features/articles/presentation/article_search_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/calculators/calculators_screen.dart';
import 'features/cases/presentation/case_screen.dart';
import 'features/flashcards/presentation/flashcard_review_screen.dart';
import 'features/home/presentation/article_list_screen.dart';
import 'features/home/presentation/subcategory_screen.dart';
import 'features/legal/disclaimer_screen.dart';
import 'features/legal/privacy_screen.dart';
import 'features/legal/terms_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/quiz/presentation/exam_results_screen.dart';
import 'features/quiz/presentation/exam_screen.dart';
import 'features/quiz/presentation/exam_setup_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/settings/presentation/system_health_screen.dart';
import 'features/subscription/presentation/paywall_screen.dart';

/// Whether Supabase was successfully initialized. False → offline/mock mode.
bool _supabaseInitialized = false;

final supabaseInitializedProvider = Provider<bool>(
  (ref) => _supabaseInitialized,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: const [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // 1. Load environment variables (.env → --dart-define → offline fallback).
  await Env.load();

  // 2. Attempt Supabase init; fall back gracefully if credentials are absent
  //    or the network is unavailable at startup.
  if (Env.isConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _supabaseInitialized = true;
    } catch (e) {
      debugPrint('Supabase init failed — running in offline mode: $e');
      _supabaseInitialized = false;
    }
  } else {
    debugPrint('Supabase credentials not configured — running in offline/mock mode.');
    _supabaseInitialized = false;
  }

  runApp(const ProviderScope(child: WardReadyApp()));
}

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: <RouteBase>[
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/disclaimer',
      builder: (context, state) => const DisclaimerScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/subcategories/:parentCategory',
      builder: (context, state) {
        final encoded = state.pathParameters['parentCategory'] ?? '';
        final parentCategory = Uri.decodeComponent(encoded);
        return SubcategoryScreen(parentCategory: parentCategory);
      },
    ),
    GoRoute(
      path: '/article-list/:category',
      builder: (context, state) {
        final encoded = state.pathParameters['category'] ?? '';
        final category = Uri.decodeComponent(encoded);
        return ArticleListScreen(category: category);
      },
    ),
GoRoute(
      path: '/article-detail',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is ArticleLocal) {
          return ArticleDetailScreen(article: extra);
        }
        if (extra is Map<String, dynamic>) {
          return ArticleDetailScreen(
            articleId: extra['id'] as String?,
            scrollToSection: extra['section'] as String?,
          );
        }
        return const _NotFoundScreen();
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) {
        final query = state.extra is String ? state.extra as String : null;
        return ArticleSearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/exam-setup',
      builder: (context, state) => const ExamSetupScreen(),
    ),
    GoRoute(
      path: '/exam',
      builder: (context, state) => const ExamScreen(),
    ),
    GoRoute(
      path: '/exam-results',
      builder: (context, state) => const ExamResultsScreen(),
    ),
    GoRoute(
      path: '/flashcards',
      builder: (context, state) => const FlashcardReviewScreen(),
    ),
    GoRoute(
      path: '/calculators',
      builder: (context, state) => const CalculatorsScreen(),
    ),
    GoRoute(
      path: '/calculator-detail',
      builder: (context, state) {
        final name = state.extra is String ? state.extra as String : 'Calculator';
        return CalculatorDetailScreen(name: name);
      },
    ),
    GoRoute(
      path: '/cases',
      builder: (context, state) => const ClinicalCasesScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/system-health',
      builder: (context, state) => const SystemHealthScreen(),
    ),
    GoRoute(
      path: '/db-recovery',
      builder: (context, state) => const DatabaseRecoveryScreen(),
    ),
  ],
);

class WardReadyApp extends StatelessWidget {
  const WardReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'WardReady',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: darkTheme,
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: const Center(child: Text('Page not found')),
    );
  }
}
