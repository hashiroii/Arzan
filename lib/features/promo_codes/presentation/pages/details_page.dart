import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vote_button.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/usecases/get_promo_code_by_id.dart';
import '../../domain/usecases/vote_promo_code.dart';
import '../providers/promo_code_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../user/domain/repositories/user_repository.dart';

class DetailsPage extends ConsumerStatefulWidget {
  final String promoCodeId;

  const DetailsPage({
    super.key,
    required this.promoCodeId,
  });

  @override
  ConsumerState<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends ConsumerState<DetailsPage> {
  PromoCode? _promoCode;

  @override
  void initState() {
    super.initState();
    _loadPromoCode();
  }

  Future<void> _loadPromoCode() async {
    final useCase = ref.read(getPromoCodeByIdProvider);
    final result = await useCase(widget.promoCodeId);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Translations.error}: ${failure.message}')),
        );
      },
      (promoCode) {
        setState(() {
          _promoCode = promoCode;
        });
      },
    );
  }

  Future<void> _handleVote(bool isUpvote) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Translations.pleaseSignInToVote)),
      );
      return;
    }

    if (_promoCode == null) return;

    final wasUpvoted = _promoCode!.upvotedBy.contains(currentUser.id);
    final wasDownvoted = _promoCode!.downvotedBy.contains(currentUser.id);

    List<String> newUpvotedBy = List.from(_promoCode!.upvotedBy);
    List<String> newDownvotedBy = List.from(_promoCode!.downvotedBy);
    int newUpvotes = _promoCode!.upvotes;
    int newDownvotes = _promoCode!.downvotes;

    if (isUpvote) {
      if (wasUpvoted) {
        newUpvotedBy.remove(currentUser.id);
        newUpvotes = (newUpvotes - 1).clamp(0, double.infinity).toInt();
      } else {
        if (wasDownvoted) {
          newDownvotedBy.remove(currentUser.id);
          newDownvotes = (newDownvotes - 1).clamp(0, double.infinity).toInt();
        }
        newUpvotedBy.add(currentUser.id);
        newUpvotes = newUpvotes + 1;
      }
    } else {
      if (wasDownvoted) {
        newDownvotedBy.remove(currentUser.id);
        newDownvotes = (newDownvotes - 1).clamp(0, double.infinity).toInt();
      } else {
        if (wasUpvoted) {
          newUpvotedBy.remove(currentUser.id);
          newUpvotes = (newUpvotes - 1).clamp(0, double.infinity).toInt();
        }
        newDownvotedBy.add(currentUser.id);
        newDownvotes = newDownvotes + 1;
      }
    }

    setState(() {
      _promoCode = _promoCode!.copyWith(
        upvotes: newUpvotes.clamp(0, double.infinity).toInt(),
        downvotes: newDownvotes.clamp(0, double.infinity).toInt(),
        upvotedBy: newUpvotedBy,
        downvotedBy: newDownvotedBy,
      );
    });

    final upvoteUseCase = ref.read(upvotePromoCodeProvider);
    final downvoteUseCase = ref.read(downvotePromoCodeProvider);
    final removeVoteUseCase = ref.read(removeVoteProvider);

    try {
      if (isUpvote) {
        if (wasUpvoted) {
          await removeVoteUseCase(widget.promoCodeId, currentUser.id);
        } else {
          if (wasDownvoted) {
            await removeVoteUseCase(widget.promoCodeId, currentUser.id);
          }
          await upvoteUseCase(widget.promoCodeId, currentUser.id);
        }
      } else {
        if (wasDownvoted) {
          await removeVoteUseCase(widget.promoCodeId, currentUser.id);
        } else {
          if (wasUpvoted) {
            await removeVoteUseCase(widget.promoCodeId, currentUser.id);
          }
          await downvoteUseCase(widget.promoCodeId, currentUser.id);
        }
      }
      
      ref.read(promoCodesNotifierProvider.notifier).updatePromoCodeVote(
        widget.promoCodeId,
        currentUser.id,
        isUpvote,
      );
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _loadPromoCode().catchError((e) {
            AppLogger.error('Background refresh error', e, null, 'Details');
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${Translations.failedToVote}: $e')),
        );
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _loadPromoCode();
          }
        });
      }
    }
  }

  void _sharePromoCode() {
    if (_promoCode != null) {
      Share.share(
        'Check out this promo code for ${_promoCode!.serviceName}: ${_promoCode!.code}',
      );
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    if (_promoCode?.author == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.blockUser),
        content: Text(
          Translations.blockUserMessage.replaceAll('this user', _promoCode!.author!.displayName ?? Translations.anonymous),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(Translations.block),
          ),
        ],
      ),
    );

    if (confirmed == true && _promoCode?.author != null) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      try {
        final result = await DependencyInjection.userRepository.blockUser(
          currentUser.id,
          _promoCode!.authorId,
        );
        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${Translations.failedToBlockUser}: ${failure.message}')),
              );
            }
          },
          (_) async {
            if (mounted) {
              ref.invalidate(authStateProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(Translations.userBlockedSuccess)),
              );
              await Future.delayed(const Duration(milliseconds: 500));
              ref.read(promoCodesNotifierProvider.notifier).loadPromoCodes(refresh: true);
              if (mounted) {
                Navigator.pop(context);
              }
            }
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${Translations.failedToBlockUser}: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePromoCode(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translations.deletePromoCode),
        content: Text(Translations.deletePromoCodeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(Translations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(Translations.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && _promoCode != null) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final repo = DependencyInjection.promoCodeRepository;
        final result = await repo.deletePromoCode(_promoCode!.id, currentUser.id);
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${Translations.error}: ${failure.message ?? Translations.failedToDelete}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(Translations.promoCodeDeleted)),
            );
            Navigator.of(context).pop();
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    if (_promoCode == null) {
      return Scaffold(
        appBar: AppBar(title: Text(Translations.promoCodeDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final promoCode = _promoCode!;
    final isExpired = promoCode.isExpired;
    final isUpvoted = currentUser != null && 
        promoCode.upvotedBy.contains(currentUser.id) &&
        !promoCode.downvotedBy.contains(currentUser.id);
    final isDownvoted = currentUser != null && 
        promoCode.downvotedBy.contains(currentUser.id) &&
        !promoCode.upvotedBy.contains(currentUser.id);

    final isOwner = currentUser != null && promoCode.authorId == currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.promoCodeDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePromoCode,
          ),
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deletePromoCode(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${Translations.karma}: ${promoCode.karma}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              promoCode.serviceName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        promoCode.code,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.black,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy, size: 28),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: promoCode.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(Translations.copied(promoCode.code)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: 'Copy promo code',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (promoCode.author != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: promoCode.author!.photoUrl != null
                                ? NetworkImage(promoCode.author!.photoUrl!)
                                : null,
                            backgroundColor: theme.colorScheme.primary,
                            child: promoCode.author!.photoUrl == null
                                ? Text(
                                    promoCode.author!.displayName?[0].toUpperCase() ?? 'U',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppColors.black,
                                        ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        promoCode.author!.displayName ?? Translations.anonymous,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                    ),
                                    if (currentUser != null && 
                                        promoCode.authorId != currentUser.id)
                                      TextButton.icon(
                                        icon: const Icon(Icons.block, size: 18),
                                        label: Text(Translations.block),
                                        onPressed: () => _blockUser(context),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${Translations.credibility}: ${promoCode.author!.karma}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (promoCode.comment != null && promoCode.comment!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          Translations.comment,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          promoCode.comment!,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: Translations.published,
                      value: _formatDate(promoCode.publishDate),
                    ),
                    if (promoCode.expirationDate != null) ...[
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: isExpired ? Icons.cancel_outlined : Icons.access_time,
                        label: Translations.expires,
                        value: _formatDate(promoCode.expirationDate!),
                        isExpired: isExpired,
                      ),
                    ],
                    if (!isExpired) ...[
                      const SizedBox(height: 16),
                      _DetailRow(
                        icon: Icons.check_circle,
                        label: Translations.status,
                        value: Translations.active,
                        isExpired: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vote section - aligned to the right
            Align(
              alignment: Alignment.centerRight,
              child: VoteButton(
                isUpvoted: isUpvoted,
                isDownvoted: isDownvoted,
                upvotes: promoCode.upvotes,
                downvotes: promoCode.downvotes,
                onUpvote: () => _handleVote(true),
                onDownvote: () => _handleVote(false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isExpired;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isExpired ? AppColors.error : null),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isExpired ? AppColors.error : null,
              ),
        ),
      ],
    );
  }
}
