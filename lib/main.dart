import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'features/auth/presentation/login_screen.dart';
import 'app/main_shell.dart'; // This is your new bottom nav shell
import 'features/subscription/presentation/paywall_screen.dart';
import 'features/subscription/data/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to Auth State (Login/Logout)
    final authState = Supabase.instance.client.auth.onAuthStateChange;

    return MaterialApp(
      title: 'EthioMed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Navy
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFB300), // Gold
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: authState,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;

          if (session == null) {
            // User not logged in? Show Login Screen
            return const LoginScreen();
          } else {
            // User is logged in? Check if they have paid
            return const SubscriptionGuard();
          }
        },
      ),
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Sync Error: $err")),
      ),
    );
  }
}