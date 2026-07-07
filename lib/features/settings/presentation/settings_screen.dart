import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/error_logger_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../auth/data/auth_service.dart';
import '../../../main.dart' show currentAdminProfileProvider;

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

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final items = <Widget>[
      ListTile(
        leading: Icon(Icons.person, color: primaryColor),
        title: const Text('Account'),
        subtitle: Text(user?.email ?? 'Not logged in'),
      ),
      SwitchListTile(
        value: dailyRemindersEnabled,
        title: const Text('Daily study reminders'),
        subtitle: const Text('Remind me at 8:00 AM when SM-2 cards are due'),
        secondary: Icon(Icons.notifications, color: primaryColor),
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
        secondary: Icon(Icons.dark_mode, color: primaryColor),
        onChanged: (enabled) async {
          final newMode = enabled ? ThemeMode.dark : ThemeMode.light;
          await saveThemeMode(newMode);
          ref.read(themeModeProvider.notifier).state = newMode;
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
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Some features may need a fresh install.',
                  style: TextStyle(color: primaryColor),
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
                leading: Icon(Icons.admin_panel_settings, color: primaryColor),
                title: const Text('Admin Dashboard'),
                subtitle: const Text('Manage user subscriptions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/admin'),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (e, s) => Center(child: Text('Error loading admin status')),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Social & Support',
          style: TextStyle(
            color: onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.share, color: primaryColor),
        title: const Text('Share WardReady'),
        onTap: () async {
          try {
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
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not open share menu.")),
            );
          }
        },
      ),
      ListTile(
        leading: Icon(Icons.bug_report, color: primaryColor),
        title: const Text('Report Medical Error'),
        onTap: _openAdminTelegram,
      ),
      ListTile(
        leading: Icon(Icons.help_outline, color: primaryColor),
        title: const Text('Technical Support'),
        subtitle: const Text('support@wardready.app'),
        onTap: _openAdminTelegram,
      ),
      ListTile(
        leading: Icon(Icons.copy_all, color: primaryColor),
        title: const Text('Copy Debug Logs'),
        subtitle: const Text('Use this if technical support asks for logs'),
        onTap: () async {
          final logs = await ErrorLoggerService.getLogs();
          await Clipboard.setData(ClipboardData(text: logs));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logs copied to clipboard!')),
          );
        },
      ),
      ListTile(
        leading: Icon(Icons.feedback, color: primaryColor),
        title: const Text('Support & Feedback'),
        subtitle: const Text('Send us your questions and suggestions'),
        onTap: () async {
          final emailLaunchUri = Uri(
            scheme: 'mailto',
            path: 'support@wardready.app',
            query: 'subject=WardReady Feedback',
          );
          if (await canLaunchUrl(emailLaunchUri)) {
            await launchUrl(emailLaunchUri);
          }
        },
      ),
      const Divider(),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          'Legal',
          style: TextStyle(
            color: onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.description, color: primaryColor),
        title: const Text('Terms of Service'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/terms'),
      ),
      ListTile(
        leading: Icon(Icons.science, color: primaryColor),
        title: const Text('Lab Reference'),
        subtitle: const Text('Ethiopian lab values and drug doses'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/lab-reference'),
      ),
      ListTile(
        leading: Icon(Icons.privacy_tip, color: primaryColor),
        title: const Text('Privacy Policy'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/privacy'),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: () async {
          try {
            await ref.read(authServiceProvider).signOut();
            if (context.mounted) context.go('/login');
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to sign out. Please try again.")),
            );
          }
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          _appVersion,
          textAlign: TextAlign.center,
          style: TextStyle(color: onSurfaceVariant, fontSize: 13),
        ),
      ),
    ];

    // Add System Health in debug mode (hidden from users in release)
    if (kDebugMode) {
      items.add(
        ListTile(
          leading: Icon(Icons.health_and_safety, color: primaryColor),
          title: const Text('System Health'),
          subtitle: const Text('Debug: View sync and security audit'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/system-health'),
        ),
      );
    }
    return items;
  }
}