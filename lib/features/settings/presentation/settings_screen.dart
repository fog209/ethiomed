import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/notification_service.dart';
import '../../admin/data/admin_repository.dart';
import '../../auth/data/auth_service.dart';
import '../../../../../main.dart';

class SettingsScreen extends ConsumerWidget {
  static const String _adminTelegramUrl = 'https://t.me/WardReadyAdmin';
  static const String _shareMessage =
      'Check out WardReady — the offline medical library for Ethiopian students! Download here: [Link]';
  static const String _appVersion = 'WardReady v1.0.0 (Beta)';

  const SettingsScreen({super.key});

  static Future<void> _openAdminTelegram() async {
    final url = Uri.parse(_adminTelegramUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(currentAdminProfileProvider);
    final dailyRemindersEnabled = ref.watch(dailyStudyRemindersEnabledProvider);
    final themeMode = ref.watch(themeModeProvider);
    final migrationWarning = MigrationErrorStore.value;
    final items = _buildItems(
      context,
      ref,
      isAdminAsync,
      dailyRemindersEnabled,
      themeMode,
      migrationWarning,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildItems(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> isAdminAsync,
    bool dailyRemindersEnabled,
    ThemeMode themeMode,
    String? migrationWarning,
  ) {
    final user = ref.watch(authSessionProvider).value?.user;

    return [
      ListTile(
        leading: const Icon(Icons.person, color: Color(0xFF1A237E)),
        title: const Text('Account'),
        subtitle: Text(user?.email ?? 'Not logged in'),
      ),
      SwitchListTile(
        value: dailyRemindersEnabled,
        title: const Text('Daily study reminders'),
        subtitle: const Text('Remind me at 8:00 AM when SM-2 cards are due'),
        secondary: const Icon(Icons.notifications, color: Color(0xFF1A237E)),
        onChanged: (enabled) async {
          await ref
              .read(dailyStudyRemindersEnabledProvider.notifier)
              .setEnabled(enabled);
          if (!context.mounted) {
            return;
          }
        },
      ),
      SwitchListTile(
        value: themeMode == ThemeMode.dark,
        title: const Text('Dark Mode'),
        subtitle: const Text('Use dark theme throughout the app'),
        secondary: const Icon(Icons.dark_mode, color: Color(0xFF1A237E)),
        onChanged: (enabled) async {
          final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
          ref.read(themeModeProvider.notifier).state = newMode;
          await saveThemeMode(newMode);
          if (!context.mounted) {
            return;
          }
        },
      ),
      if (migrationWarning != null)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF1A237E)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Some features may need a fresh install.',
                  style: const TextStyle(color: Color(0xFF1A237E)),
                ),
              ),
            ],
          ),
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
                onTap: () => context.push('/admin'),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Social & Support',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.share, color: Color(0xFF1A237E)),
        title: const Text('Share WardReady'),
        onTap: () async {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            await Share.share(
              _shareMessage,
              sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
            );
            if (!context.mounted) {
              return;
            }
          }
        },
      ),
      ListTile(
        leading: const Icon(Icons.bug_report, color: Color(0xFF1A237E)),
        title: const Text('Report Medical Error'),
        onTap: _openAdminTelegram,
      ),
      ListTile(
        leading: const Icon(Icons.help_outline, color: Color(0xFF1A237E)),
        title: const Text('Technical Support'),
        onTap: _openAdminTelegram,
      ),
      const Divider(),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Legal',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTile(
        leading: const Icon(Icons.description, color: Color(0xFF1A237E)),
        title: const Text('Terms of Service'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/terms'),
      ),
      ListTile(
        leading: const Icon(Icons.privacy_tip, color: Color(0xFF1A237E)),
        title: const Text('Privacy Policy'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/privacy'),
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
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          _appVersion,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ),
    ];
  }
}
