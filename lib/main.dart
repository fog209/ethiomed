import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/services/error_logger_service.dart';
import 'app/env.dart';
import 'app/main_shell.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/env_guard.dart';
import 'core/screens/database_recovery_screen.dart';
import 'core/services/security_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/admin/presentation/admin_dashboard_screen.dart';
import 'features/articles/presentation/article_detail_screen.dart';
import 'features/articles/presentation/article_search_screen.dart';
import 'features/search/presentation/spotlight_search_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/calculators/calculators_screen.dart' show CalculatorsScreen, CalculatorDetailScreen;
import 'features/cases/presentation/case_screen.dart';
import 'features/flashcards/presentation/flashcard_stage_prompt_screen.dart';
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
import 'features/progress/progress_screen.dart';
import 'features/settings/presentation/system_health_screen.dart';
import 'features/settings/presentation/forced_update_gate.dart';
import 'features/settings/presentation/forced_update_screen.dart';
import 'features/subscription/presentation/paywall_screen.dart';
import 'features/subscription/data/subscription_repository.dart';

bool _supabaseInitialized = false;
bool _tampered = false;

final supabaseInitializedProvider = Provider<bool>((ref) => _supabaseInitialized);
final isTamperedProvider = Provider<bool>((ref) => _tampered);

final onboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
});

final currentAdminProfileProvider = FutureProvider<bool>((ref) async {
  if (!_supabaseInitialized) return false;
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return false;
  try {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('is_admin')
        .eq('id', user.id)
        .maybeSingle();
    return profile?['is_admin'] == true;
  } catch (e) {
    debugPrint('Admin profile check failed: $e');
    return false;
  }
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: const [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  if (kReleaseMode) {
    final security = SecurityService();
    _tampered = !await security.initialize();
  }

  await Env.load();

  // Fail loudly (in debug) on placeholder/missing credentials rather than
  // silently degrading to offline mode. Release builds keep the offline
  // fallback, so only assert here.
  assert(
    () {
      validateEnvConfig(<String, String>{
        'supabaseUrl': Env.supabaseUrl,
        'supabaseAnonKey': Env.supabaseAnonKey,
      });
      return true;
    }(),
    'Environment configuration is invalid — see validateEnvConfig error.',
  );

  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorLoggerService.logError(details.exceptionAsString(), details.stack);
    if (firebaseInitialized) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorLoggerService.logError(error.toString(), stack);
    if (firebaseInitialized) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
    return true;
  };

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

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith(
          (ref) {
            final savedIndex = prefs.getInt('themeMode');
            if (savedIndex == null ||
                savedIndex < 0 ||
                savedIndex >= ThemeMode.values.length) {
              return ThemeMode.dark;
            }
            return ThemeMode.values[savedIndex];
          },
        ),
      ],
      child: const WardReadyApp(),
    ),
  );
}

bool _isAtLoginOrSubscription(String location) {
  return location == '/login' || location == '/subscription' || location == '/signup';
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasSeenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false;
    final location = state.uri.path;

    // 0. Forced-update gate — highest priority. An installed version below the
    // hardcoded minimum ([kMinimumSupportedVersion]) blocks everything, even
    // offline, by routing to the non-dismissible update screen. Computed
    // synchronously from constants (no Provider/ref needed in the router).
    if (isVersionUnsupported(kInstalledAppVersion, kMinimumSupportedVersion)) {
      if (location != '/forced-update') return '/forced-update';
      return null;
    }

    // 1. Onboarding gate (only fires if not already on the onboarding route)
    if (!hasSeenOnboarding) {
      if (location != '/onboarding') return '/onboarding';
      return null;
    }

    // 2. Disclaimer gate (only fires if not already on the disclaimer route)
    if (!hasSeenDisclaimer) {
      if (location != '/disclaimer') return '/disclaimer';
      return null;
    }

    // 3. Auth gate — skipped entirely when Supabase is not configured
    if (!_supabaseInitialized) {
      debugPrint('Router: Supabase not initialized — skipping auth/subscription gate.');
      if (location == '/') return '/home';
      return null;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      debugPrint('Router: No auth session — redirecting to /login.');
      if (!_isAtLoginOrSubscription(location)) return '/login';
      return null;
    }

    // 4. Subscription / admin gate (only for authenticated users)
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('is_admin')
            .eq('id', user.id)
            .maybeSingle()
            .catchError((_) => null);
        final isAdmin = profile?['is_admin'] == true;

        // Admin-only route: block non-admins at the router level, matching
        // the strictness of the login/subscription gate. RLS also limits
        // data exposure, but the screen must not be reachable by non-admins.
        if (location == '/admin' && !isAdmin) {
          return '/home';
        }

        if (isAdmin) {
          if (location == '/') return '/home';
          return null;
        }

        final repo = SubscriptionRepository(Supabase.instance.client);
        final isSubscribed = await repo.checkSubscriptionStatus();
        if (!isSubscribed) {
          debugPrint('Router: Subscription invalid — redirecting to /subscription.');
          if (location != '/subscription') return '/subscription';
          return null;
        }
      }
    } catch (e) {
      debugPrint('Router: Subscription check error — allowing access: $e');
    }

    // 5. All checks passed — allow through (or land on Home from the root path)
    if (location == '/') return '/home';
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/forced-update',
      builder: (context, state) => const ForcedUpdateScreen(),
    ),
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
        final parentCategory = state.uri.queryParameters['parentCategory'];
        return ArticleListScreen(
          category: category,
          parentCategory: parentCategory != null ? Uri.decodeComponent(parentCategory) : null,
        );
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
      path: '/spotlight',
      builder: (context, state) {
        final query = state.extra is String ? state.extra as String : null;
        return SpotlightSearchScreen(initialQuery: query);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
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
      builder: (context, state) => const FlashcardsGate(),
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

class WardReadyApp extends ConsumerWidget {
  const WardReadyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    if (kReleaseMode && _tampered) {
      return const _SecurityAlertScreen();
    }

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
        themeMode: themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
      ),
    );
  }
}

class _SecurityAlertScreen extends StatelessWidget {
  const _SecurityAlertScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialApp(
      home: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Security Alert',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This version of WardReady has been tampered with or re-signed. Please install the official version to protect your data.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
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