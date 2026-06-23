import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/screens/database_recovery_screen.dart';
import 'core/services/notification_service.dart';
import 'features/admin/presentation/admin_dashboard_screen.dart';
import 'features/articles/presentation/article_detail_screen.dart';
import 'features/home/presentation/article_list_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/legal/disclaimer_screen.dart';
import 'features/legal/privacy_screen.dart';
import 'features/legal/terms_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'app/main_shell.dart'; // This is your new bottom nav shell
import 'features/subscription/presentation/paywall_screen.dart';
import 'features/subscription/data/subscription_repository.dart';

bool _seenOnboarding = false;
bool _seenDisclaimer = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  _seenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  _seenDisclaimer = prefs.getBool('hasSeenDisclaimer') ?? false;

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error');
    debugPrint('Stack: $stack');
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Color(0xFF1A237E)),
                SizedBox(height: 16),
                Text(
                  'Something went wrong.\nPlease restart the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }

  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  } on PostgrestException catch (e) {
    debugPrint('Supabase error: ${e.message}');
    rethrow;
  } catch (e) {
    debugPrint('Error: $e');
    rethrow;
  }

  try {
    final db = AppDatabase();
    await db.customSelect('SELECT 1').get();
    await db.close();
  } catch (e) {
    debugPrint('Database initialization failed: $e');
    runApp(const DatabaseRecoveryApp());
    return;
  }

  try {
    await NotificationService().initialize();
  } catch (error) {
    debugPrint('Notification service initialization skipped: $error');
  }

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF1A237E),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.explore_off, color: Color(0xFFF9A825), size: 64),
          const SizedBox(height: 16),
          const Text(
            'Page not found',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const InitialFlowGate()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const AppEntrance()),
    GoRoute(
      path: '/disclaimer',
      builder: (context, state) => const DisclaimerScreen(),
    ),
    GoRoute(path: '/terms', builder: (context, state) => const TermsScreen()),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyScreen(),
    ),
    GoRoute(
      path: '/article-list/:category',
      builder: (context, state) =>
          ArticleListScreen(category: state.pathParameters['category'] ?? ''),
    ),
    GoRoute(
      path: '/article-detail',
      builder: (context, state) {
        final article = state.extra;
        if (article is ArticleLocal) {
          return ArticleDetailScreen(article: article);
        }
        return ArticleDetailScreen();
      },
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);

class InitialFlowGate extends StatefulWidget {
  const InitialFlowGate({super.key});

  @override
  State<InitialFlowGate> createState() => _InitialFlowGateGateState();
}

class _InitialFlowGateGateState extends State<InitialFlowGate> {
  @override
  Widget build(BuildContext context) {
    if (!_seenOnboarding) {
      return const OnboardingScreen();
    }

    if (!_seenDisclaimer) {
      return const DisclaimerScreen();
    }

    return const MainShell();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFB300),
        ),
      ),
    );
  }
}

class DisclaimerGate extends StatefulWidget {
  const DisclaimerGate({super.key});

  @override
  State<DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<DisclaimerGate> {
  static const String _hasSeenDisclaimerKey = 'hasSeenDisclaimer';

  bool? _hasSeenDisclaimer;

  @override
  void initState() {
    super.initState();
    _loadDisclaimerState();
  }

  Future<void> _loadDisclaimerState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _hasSeenDisclaimer = prefs.getBool(_hasSeenDisclaimerKey) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenDisclaimer == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasSeenDisclaimer == true) {
      return const AppEntrance();
    }

    return const DisclaimerScreen();
  }
}

class AppEntrance extends ConsumerWidget {
  const AppEntrance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = Supabase.instance.client.auth.onAuthStateChange;

    return StreamBuilder<AuthState>(
      stream: authState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong. Pull down to retry.'),
          );
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginScreen();
        }

        return const SubscriptionGuard();
      },
    );
  }
}

// THE GATEKEEPER: This decides if the user sees the Library or the Paywall
class SubscriptionGuard extends ConsumerWidget {
  const SubscriptionGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(isSubscribedProvider);

    return isSubscribed.when(
      data: (active) {
        if (active) {
          return const MainShell(); // SUCCESS: Show the 4-tab app
        } else {
          return const PaywallScreen(); // LOCKED: Show the payment instructions
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Sync Error: $err"))),
    );
  }
}
