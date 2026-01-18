import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/promo_code_card.dart';
import '../../domain/entities/user.dart';
import '../providers/user_provider.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../promo_codes/presentation/pages/details_page.dart';
import '../../../promo_codes/domain/entities/promo_code.dart';
import '../../../promo_codes/data/repositories/promo_code_repository_impl.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId;

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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error: ${failure.message ?? "Failed to load user"}',
                ),
              ),
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
          if (mounted) {
            setState(() {
              _userPromoCodes = [];
            });
          }
        },
        (codes) {
          final sortedCodes = _sortWithExpiredAtEnd(codes);
          if (mounted) {
            setState(() {
              _userPromoCodes = sortedCodes;
            });
          }
        },
      );
    } catch (e) {
      AppLogger.error('Profile: Unexpected error', e, StackTrace.current, 'ProfilePage');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<PromoCode> _sortWithExpiredAtEnd(List<PromoCode> promoCodes) {
    final active = <PromoCode>[];
    final expired = <PromoCode>[];
    
    for (final code in promoCodes) {
      if (code.isExpired) {
        expired.add(code);
      } else {
        active.add(code);
      }
    }
    
    return [...active, ...expired];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(Translations.profile)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(Translations.profile)),
        body: Center(child: Text(Translations.userNotFound)),
      );
    }

    final isCurrentUser = currentUser?.id == _user!.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: Translations.refresh,
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
                        content: Text(
                          'Error: ${failure.message ?? "Failed to sign out"}',
                        ),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
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

                  Text(
                    _user!.displayName ?? Translations.anonymous,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _user!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

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
                    '${Translations.credibility}: ${_user!.karma}',
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

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Translations.promoCodes} (${_userPromoCodes.length})',
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
                              Translations.noPromoCodesYet,
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
                          // Refresh profile data when returning from details
                          if (mounted) {
                            _refreshData();
                          }
                        },
                        onUpvote:
                            null, // Disable voting on own codes in profile
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
