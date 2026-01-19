import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/utils/translations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../promo_codes/presentation/providers/promo_code_provider.dart';

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

  Future<List<Map<String, dynamic>>> _loadBlockedUsers(List<String> userIds) async {
    final userRepo = DependencyInjection.userRepository;
    final users = <Map<String, dynamic>>[];
    
    for (final userId in userIds) {
      final result = await userRepo.getUserById(userId);
      result.fold(
        (failure) => null,
        (user) {
          users.add({
            'id': user.id,
            'displayName': user.displayName,
            'email': user.email,
            'photoUrl': user.photoUrl,
          });
        },
      );
    }
    
    return users;
  }

  Future<void> _unblockUser(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.unblockUser),
        content: Text(Translations.unblockUserMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(Translations.unblock),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final userRepo = DependencyInjection.userRepository;
        final result = await userRepo.unblockUser(currentUser.id, userId);
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message ?? "Failed to unblock user"}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) async {
            ref.invalidate(authStateProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(Translations.userUnblockedSuccess)),
            );
            await Future.delayed(const Duration(milliseconds: 500));
            ref.read(promoCodesNotifierProvider.notifier).loadPromoCodes(refresh: true);
            setState(() {});
          },
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.deleteAccount),
        content: Text(Translations.deleteAccountMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Translations.delete),
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
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.settings),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _SettingsSection(
            title: Translations.language,
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
            title: Translations.appearance,
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

          _SettingsSection(
            title: Translations.notifications,
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: Text(Translations.pushNotifications),
                subtitle: Text(Translations.receiveNotifications),
                value: _notificationEnabled,
                onChanged: (value) => _requestNotificationPermission(),
                secondary: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Feedback Section
          _SettingsSection(
            title: Translations.feedback,
            icon: Icons.feedback,
            children: [
              ListTile(
                leading: const Icon(Icons.star),
                title: Text(Translations.rateApp),
                subtitle: Text(Translations.leaveReview),
                trailing: const Icon(Icons.chevron_right),
                onTap: _openFeedback,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About Section
          _SettingsSection(
            title: Translations.about,
            icon: Icons.info,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(Translations.version),
                subtitle: Text(_appVersion.isEmpty ? Translations.loading : _appVersion),
              ),
              ListTile(
                leading: const Icon(Icons.apps),
                title: Text(Translations.appNameLabel),
                subtitle: Text(Translations.appName),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account Section
          _SettingsSection(
            title: Translations.account,
            icon: Icons.account_circle,
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(Translations.signOut),
                subtitle: Text(Translations.signOutMessage),
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
                    },
                  );
                },
              ),
              Builder(
                builder: (context) {
                  final currentUser = ref.watch(currentUserProvider);
                  final blockedUserIds = currentUser?.blockedUsers ?? [];
                  
                  if (blockedUserIds.isEmpty) {
                    return ListTile(
                      leading: const Icon(Icons.block),
                      title: Text(Translations.blockedUsers),
                      subtitle: Text(Translations.noBlockedUsers),
                      enabled: false,
                    );
                  }
                  
                  return ExpansionTile(
                    leading: const Icon(Icons.block),
                    title: Text(Translations.blockedUsers),
                    subtitle: Text('${blockedUserIds.length} ${Translations.usersBlocked}'),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _loadBlockedUsers(blockedUserIds),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            );
                          }
                          
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(Translations.failedToLoadBlockedUsers),
                            );
                          }
                          
                          final blockedUsers = snapshot.data!;
                          if (blockedUsers.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(Translations.noBlockedUsers),
                            );
                          }
                          
                          return Column(
                            children: blockedUsers.map((user) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user['photoUrl'] != null
                                      ? NetworkImage(user['photoUrl'])
                                      : null,
                                  child: user['photoUrl'] == null
                                      ? Text(user['displayName']?[0] ?? 'U')
                                      : null,
                                ),
                                title: Text(user['displayName'] ?? Translations.anonymous),
                                subtitle: Text(user['email'] ?? ''),
                                trailing: TextButton.icon(
                                  icon: const Icon(Icons.block, size: 18),
                                  label: Text(Translations.unblock),
                                  onPressed: () => _unblockUser(context, user['id']),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: Text(Translations.deleteAccount),
                subtitle: Text(Translations.deleteAccountMessage),
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
                        : theme.colorScheme.onSurface,
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
    final isSystemLocale = locale.languageCode == 
        (PlatformDispatcher.instance.locale.languageCode == 'ru' ? 'ru' : 'en');
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(Translations.language),
      subtitle: Text(
        locale.languageCode == 'en' 
            ? Translations.english 
            : locale.languageCode == 'ru'
                ? Translations.russian
                : Translations.systemDefault,
      ),
      trailing: DropdownButton<Locale?>(
        value: locale,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<Locale?>(
            value: null,
            child: Row(
              children: [
                const Icon(Icons.settings, size: 18),
                const SizedBox(width: 8),
                Text(Translations.systemDefault),
              ],
            ),
          ),
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text(Translations.english),
          ),
          DropdownMenuItem(
            value: const Locale('ru'),
            child: Text(Translations.russian),
          ),
        ],
        onChanged: (value) async {
          if (value == null) {
            final systemLocale = PlatformDispatcher.instance.locale;
            final systemLanguageCode = AppConstants.supportedLanguages.contains(systemLocale.languageCode)
                ? systemLocale.languageCode
                : AppConstants.defaultLanguage;
            final systemLocaleFinal = Locale(systemLanguageCode);
            onLocaleChanged(systemLocaleFinal);
            await SharedPreferences.getInstance().then((prefs) => prefs.remove('selected_locale'));
          } else {
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
          title: Text(Translations.systemDefault),
          value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) {
              onThemeModeChanged(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(Translations.light),
          value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (value) {
            if (value != null) {
              onThemeModeChanged(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(Translations.dark),
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
