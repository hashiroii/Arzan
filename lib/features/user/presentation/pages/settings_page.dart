import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/utils/translations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/dependency_injection.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appVersion = '';
  bool _notificationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _notificationEnabled = status.isGranted;
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  Future<void> _requestNotificationPermission() async {
    // Check current status first
    final currentStatus = await Permission.notification.status;
    
    if (currentStatus.isGranted) {
      // Toggle off
      setState(() {
        _notificationEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications disabled')),
        );
      }
      return;
    }
    
    if (currentStatus.isPermanentlyDenied) {
      if (mounted) {
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'Notification permission is permanently denied. Please enable it in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        
        if (shouldOpen == true) {
          await openAppSettings();
          // Check again after opening settings
          await _checkNotificationPermission();
        }
      }
      return;
    }
    
    // Request permission
    final status = await Permission.notification.request();
    setState(() {
      _notificationEnabled = status.isGranted;
    });
    
    if (status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission granted')),
        );
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification permission denied')),
        );
      }
    }
  }

  Future<void> _openFeedback() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.arzan.app',
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

    if (confirmed == true && mounted) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final userRepo = DependencyInjection.userRepository;
        await userRepo.deleteUser(currentUser.id);

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
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _SettingsSection(
            title: 'Language',
            icon: Icons.language,
            children: [
              _LanguageTile(
                locale: locale,
                onLocaleChanged: (newLocale) async {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                  await Translations.load(newLocale);
                  if (mounted) {
                    setState(() {}); // Trigger rebuild to show new translations
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Theme Section
          _SettingsSection(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              _ThemeTile(
                themeMode: themeMode,
                onThemeModeChanged: (mode) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive notifications about new promo codes'),
                value: _notificationEnabled,
                onChanged: (value) => _requestNotificationPermission(),
                secondary: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Feedback Section
          _SettingsSection(
            title: 'Feedback',
            icon: Icons.feedback,
            children: [
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Rate App'),
                subtitle: const Text('Leave a review on Play Store / App Store'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openFeedback,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Section
          _SettingsSection(
            title: 'About',
            icon: Icons.info,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: Text(_appVersion.isEmpty ? 'Loading...' : _appVersion),
              ),
              ListTile(
                leading: const Icon(Icons.apps),
                title: const Text('App Name'),
                subtitle: const Text('Arzan'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Section
          _SettingsSection(
            title: 'Account',
            icon: Icons.account_circle,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                subtitle: const Text('Sign out from your account'),
                onTap: () async {
                  final authRepo = DependencyInjection.authRepository;
                  final result = await authRepo.signOut();
                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${failure.message ?? "Failed to sign out"}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    },
                    (_) {
                      // Success - auth state will update automatically
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Account'),
                subtitle: const Text('Permanently delete your account and data'),
                onTap: _deleteAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface, // Use onSurface for light theme
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final Locale locale;
  final Function(Locale) onLocaleChanged;

  const _LanguageTile({
    required this.locale,
    required this.onLocaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Language'),
      subtitle: Text(locale.languageCode == 'en' ? 'English' : 'Русский'),
      trailing: DropdownButton<Locale>(
        value: locale,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: Locale('ru'),
            child: Text('Русский'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onLocaleChanged(value);
          }
        },
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeModeChanged;

  const _ThemeTile({
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('System Default'),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) {
              onThemeModeChanged(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) {
              onThemeModeChanged(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) {
              onThemeModeChanged(value);
            }
          },
        ),
      ],
    );
  }
}
