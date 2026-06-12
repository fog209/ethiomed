import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/data/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authSessionProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EthioMed'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () async {
              await authService.signOut();
              if (!context.mounted) {
                return;
              }
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: authState.when(
            data: (session) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 32),
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: const Color(0xFF1A237E),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Phase 0 foundation is ready.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF1A237E),
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    session == null
                        ? 'Authentication is initialized.'
                        : 'You are signed in and ready for offline content sync.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(191),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Next foundation steps',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          _FeatureRow(
                            icon: Icons.folder_off,
                            label: 'Offline article database',
                          ),
                          _FeatureRow(
                            icon: Icons.search,
                            label: 'Full-text search',
                          ),
                          _FeatureRow(
                            icon: Icons.payment,
                            label: 'Subscription and payment flow',
                          ),
                          _FeatureRow(
                            icon: Icons.video_library_outlined,
                            label: 'Video link playback',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
            error: (error, stackTrace) {
              debugPrint('Home auth state error: $error\n$stackTrace');
              return Center(
                child: Text(
                  'Authentication state is unavailable.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
