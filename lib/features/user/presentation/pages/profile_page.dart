import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/promo_code_card.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../promo_codes/presentation/pages/details_page.dart';
import '../../../promo_codes/domain/entities/promo_code.dart';
import '../../../promo_codes/data/repositories/promo_code_repository_impl.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId; // If null, shows current user's profile

  const ProfilePage({super.key, this.userId});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  User? _user;
  List<PromoCode> _userPromoCodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null && _user?.id != currentUser.id) {
      _loadUserData();
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  void didUpdateWidget(ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final targetUserId = widget.userId ?? ref.read(currentUserProvider)?.id;
    if (targetUserId == null) {
      AppLogger.warning('No user ID available', 'Profile');
      setState(() {
        _isLoading = false;
        _user = null;
        _userPromoCodes = [];
      });
      return;
    }

    try {
      final getUserUseCase = ref.read(getUserByIdProvider);
      final repo = DependencyInjection.promoCodeRepository;

      final codesResult = await repo.getUserPromoCodes(targetUserId);

      final promoCodeRepo = DependencyInjection.promoCodeRepository;
      if (promoCodeRepo is PromoCodeRepositoryImpl) {
        await promoCodeRepo.recalculateUserKarma(targetUserId);
      }

      final userResult = await getUserUseCase(targetUserId);

      userResult.fold(
        (failure) {
          AppLogger.error('Error loading user', failure, null, 'Profile');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message ?? "Failed to load user"}')),
            );
          }
          setState(() {
            _user = null;
          });
        },
        (user) {
          if (mounted) {
            setState(() {
              _user = user;
            });
          }
        },
      );

      codesResult.fold(
        (failure) {
          AppLogger.error('Error loading promo codes', failure, null, 'Profile');
          if (mounted) {
            setState(() {
              _userPromoCodes = [];
            });
          }
        },
        (codes) {
          if (mounted) {
            setState(() {
              _userPromoCodes = codes;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error', e, null, 'Profile');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
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
    final currentUser = ref.watch(currentUserProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    final isCurrentUser = currentUser?.id == _user!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
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
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  // Profile Photo
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _user!.photoUrl != null
                        ? NetworkImage(_user!.photoUrl!)
                        : null,
                    backgroundColor: theme.colorScheme.primary,
                    child: _user!.photoUrl == null
                        ? Text(
                            _user!.displayName?[0].toUpperCase() ?? 'U',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: AppColors.black),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Display Name
                  Text(
                    _user!.displayName ?? 'Anonymous',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _user!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // Karma
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.black),
                        const SizedBox(width: 8),
                        Text(
                          'Credibility: ${_user!.karma}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // User's Promo Codes
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promo Codes (${_userPromoCodes.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_userPromoCodes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No promo codes yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._userPromoCodes.map(
                      (code) => PromoCodeCard(
                        promoCode: code,
                        currentUserId: currentUser?.id,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsPage(promoCodeId: code.id),
                            ),
                          );
                          if (mounted) {
                            _refreshData();
                          }
                        },
                        onUpvote: null,
                        onDownvote: null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
