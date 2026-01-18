import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/utils/logger.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await DependencyInjection.authRepository.signInWithGoogle();
      result.fold(
        (failure) {
          AppLogger.error('Sign-In failed', failure, null, 'LoginPage');
          String errorMessage = 'Sign in failed';
          if (failure.message != null) {
            errorMessage = failure.message!;
            if (failure.message!.contains('Firestore database not created') ||
                failure.message!.contains('does not exist')) {
              errorMessage = 'Firestore Database Not Created!\n\nCreate it:\n1. Go to Firebase Console\n2. Click Firestore Database\n3. Click "Create database"\n4. Choose "Test mode"\n5. Select location\n6. Click "Enable"\n\nOr click: https://console.firebase.google.com/project/arzan-a8f6d/firestore';
            } else if (failure.message!.contains('Firestore API not enabled') ||
                failure.message!.contains('firestore.googleapis.com')) {
              errorMessage = 'Firestore API Not Enabled!\n\nClick to enable:\nhttps://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=arzan-a8f6d\n\nOr see ENABLE_FIRESTORE_API.md';
            } else if (failure.message!.contains('DEVELOPER_ERROR') ||
                failure.message!.contains('10:') ||
                failure.message!.contains('ApiException: 10')) {
              errorMessage = 'Google Sign-In Error (Code 10)\n\nFix:\n1. Enable Google Sign-In in Firebase Console\n2. Add SHA-1/SHA-256 fingerprints\n3. Download updated google-services.json\n\nSee FIREBASE_AUTH_FIX.md';
            } else if (failure.message!.contains('12500')) {
              errorMessage = 'Google Sign-In app not found. Check package name matches Firebase.';
            } else if (failure.message!.contains('cancelled') ||
                failure.message!.toLowerCase().contains('cancel')) {
              return;
            }
          }
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        (user) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signed in successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    size: 64,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // App Name
                Text(
                  'Arzan',
                  style: AppTextStyles.h1.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Share and discover promo codes',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.black),
                            ),
                          )
                        : const Icon(Icons.login, size: 24),
                    label: Text(
                      _isLoading ? 'Signing in...' : 'Continue with Google',
                      style: AppTextStyles.button,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.onSurface,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          try {
                            final result = await DependencyInjection.authRepository
                                .signInAnonymously();
                            result.fold(
                              (failure) {
                                AppLogger.error('Anonymous sign-in failed', failure, null, 'LoginPage');
                                if (mounted) {
                                  String errorMsg = failure.message ?? 'Unknown error';
                                  if (errorMsg.contains('OPERATION_NOT_ALLOWED') ||
                                      errorMsg.contains('CONFIGURATION_NOT_FOUND')) {
                                    errorMsg = 'Anonymous sign-in not enabled!\n\nFix: Go to Firebase Console → Authentication → Sign-in method → Enable "Anonymous"\n\nSee FIREBASE_AUTH_FIX.md for details.';
                                  } else if (errorMsg.contains('admin-restricted-operation')) {
                                    errorMsg = 'Anonymous sign-in is restricted.\n\nFix: Go to Firebase Console → Authentication → Sign-in method → Anonymous → Remove restrictions → Save';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sign in failed: $errorMsg'),
                                      backgroundColor: AppColors.error,
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                              (user) {},
                            );
                          } catch (e) {
                            AppLogger.error('Exception during anonymous sign-in', e, null, 'LoginPage');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        },
                  child: const Text('Continue as Guest (Testing)'),
                ),
                const SizedBox(height: 16),

                // Info Text
                Text(
                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
