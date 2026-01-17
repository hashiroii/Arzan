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
          SnackBar(content: Text('Error: ${failure.message}')),
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

    if (newUpvotedBy.contains(currentUser.id)) {
      newUpvotedBy.remove(currentUser.id);
      newUpvotes = (newUpvotes - 1).clamp(0, double.infinity).toInt();
    }
    if (newDownvotedBy.contains(currentUser.id)) {
      newDownvotedBy.remove(currentUser.id);
      newDownvotes = (newDownvotes - 1).clamp(0, double.infinity).toInt();
    }

    if (isUpvote) {
      if (!wasUpvoted) {
        newUpvotedBy.add(currentUser.id);
        newUpvotes = newUpvotes + 1;
      }
    } else {
      if (!wasDownvoted) {
        newDownvotedBy.add(currentUser.id);
        newDownvotes = newDownvotes + 1;
      }
    }

    setState(() {
      _promoCode = _promoCode!.copyWith(
        upvotes: newUpvotes,
        downvotes: newDownvotes,
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
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _loadPromoCode().catchError((e) {
            AppLogger.error('Background refresh error', e, null, 'Details');
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to vote: $e')),
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

  Future<void> _deletePromoCode(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Promo Code'),
        content: const Text(
          'Are you sure you want to delete this promo code? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
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
                content: Text('Error: ${failure.message ?? "Failed to delete"}'),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Promo code deleted')),
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
        appBar: AppBar(title: const Text('Promo Code Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final promoCode = _promoCode!;
    final isExpired = promoCode.isExpired;
    final isUpvoted = currentUser != null && promoCode.upvotedBy.contains(currentUser.id);
    final isDownvoted = currentUser != null && promoCode.downvotedBy.contains(currentUser.id);

    final isOwner = currentUser != null && promoCode.authorId == currentUser.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Code Details'),
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
            // Service name
            Text(
              promoCode.serviceName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Promo Code - Biggest with Copy Button
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
                              color: AppColors.black, // Black text for better visibility on yellow
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
                  color: theme.colorScheme.primary,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: theme.colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Author info with photo and name
            if (promoCode.author != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                            Text(
                              promoCode.author!.displayName ?? 'Anonymous',
                              style: Theme.of(context).textTheme.titleLarge,
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
                                  'Credibility: ${promoCode.author!.karma}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Comment
            if (promoCode.comment != null && promoCode.comment!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comment',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        promoCode.comment!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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
                      label: 'Published',
                      value: _formatDate(promoCode.publishDate),
                    ),
                    if (promoCode.expirationDate != null) ...[
                      const Divider(),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Expires',
                        value: _formatDate(promoCode.expirationDate!),
                        isExpired: isExpired,
                      ),
                    ],
                    const Divider(),
                    _DetailRow(
                      icon: Icons.check_circle,
                      label: 'Status',
                      value: isExpired ? 'Expired' : 'Active',
                      isExpired: isExpired,
                    ),
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
