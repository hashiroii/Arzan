import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../../core/utils/dependency_injection.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission granted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission denied')),
      );
    }
  }

  Future<void> _openFeedback() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.arzan.app', // Replace with actual ID, I'll do it later
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        // Delete user data
        final userRepo = DependencyInjection.userRepository;
        await userRepo.deleteUser(currentUser.id);

        // Sign out
        final authRepo = DependencyInjection.authRepository;
        await authRepo.signOut();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Language Section
          _SectionHeader(title: 'Language'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: Text(locale.languageCode == 'en' ? 'English' : 'Русский'),
            trailing: DropdownButton<Locale>(
              value: locale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                }
              },
            ),
          ),
          const Divider(),

          // Theme Section
          _SectionHeader(title: 'Theme'),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Enable push notifications'),
            trailing: Switch(
              value: false, // TODO: Implement notification state
              onChanged: (value) {
                _requestNotificationPermission();
              },
            ),
          ),
          const Divider(),

          // Feedback Section
          _SectionHeader(title: 'Feedback'),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Rate App'),
            subtitle: const Text('Leave a review on Play Store / App Store'),
            onTap: _openFeedback,
          ),
          const Divider(),

          // About Section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Version'),
            subtitle: Text(_appVersion.isEmpty ? 'Loading...' : _appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.apps),
            title: const Text('App Icon'),
            subtitle: const Text('Arzan'),
          ),
          const Divider(),

          // Account Section
          _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Permanently delete your account'),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
