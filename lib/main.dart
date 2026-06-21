import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/signup_screen.dart';
import 'features/legal/disclaimer_screen.dart';
import 'app/main_shell.dart'; // This is your new bottom nav shell
import 'features/subscription/presentation/paywall_screen.dart';
import 'features/subscription/data/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DisclaimerGate()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const AppEntrance()),
  ],
);

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

  Future<void> _acceptDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenDisclaimerKey, true);
    if (!mounted) {
      return;
    }

    setState(() {
      _hasSeenDisclaimer = true;
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

    return DisclaimerScreen(onAccepted: _acceptDisclaimer);
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
