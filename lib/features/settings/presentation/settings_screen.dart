import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../auth/data/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    final isAdminAsync = ref.watch(currentAdminProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1A237E)),
            title: const Text('Account'),
            subtitle: Text(user?.email ?? 'Not logged in'),
          ),
          isAdminAsync.when(
            data: (isAdmin) {
              if (!isAdmin) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF1A237E),
                    ),
                    title: const Text('Admin Dashboard'),
                    subtitle: const Text('Manage user subscriptions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const AdminDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
