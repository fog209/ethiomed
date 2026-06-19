// ignore_for_file: depend_on_referenced_packages, uri_does_not_exist, undefined_identifier
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../admin/data/admin_repository.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../auth/data/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  static const String _adminTelegramUrl = 'https://t.me/WardReadyAdmin';

  const SettingsScreen({super.key});

  static Future<void> _openAdminTelegram() async {
    final url = Uri.parse(_adminTelegramUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Support & Feedback',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report, color: Color(0xFF1A237E)),
            title: const Text('Report a Medical Error'),
            onTap: _openAdminTelegram,
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
            title: const Text('Subscription Help'),
            onTap: _openAdminTelegram,
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Color(0xFF1A237E)),
            title: const Text('Share WardReady'),
            onTap: () {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                Share.share(
                  'Check out WardReady — the offline medical library for Ethiopian students!',
                  sharePositionOrigin:
                      box.localToGlobal(Offset.zero) & box.size,
                );
              }
            },
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
