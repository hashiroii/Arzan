import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/promo_code_card.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../promo_codes/presentation/pages/details_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final String? userId; // If null, shows current user's profile

  const ProfilePage({super.key, this.userId});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  User? _user;
  List<dynamic> _userPromoCodes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final targetUserId = widget.userId ?? ref.read(currentUserProvider)?.id;
    if (targetUserId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Load user
    final getUserByIdProvider = Provider<GetUserById>((ref) {
      return GetUserById(DependencyInjection.userRepository);
    });
    final getUserUseCase = ref.read(getUserByIdProvider);
    final userResult = await getUserUseCase(targetUserId);
    userResult.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}')));
      },
      (user) {
        setState(() {
          _user = user;
        });
      },
    );

    // Load user's promo codes
    final repo = DependencyInjection.promoCodeRepository;
    final codesResult = await repo.getUserPromoCodes(targetUserId);
    codesResult.fold(
      (failure) {
        // Silent fail for codes
        setState(() {
          _userPromoCodes = [];
        });
      },
      (codes) {
        setState(() {
          _userPromoCodes = codes;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
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

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
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

                  // Email
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
                          'Karma: ${_user!.karma}',
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailsPage(promoCodeId: code.id),
                            ),
                          );
                        },
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
