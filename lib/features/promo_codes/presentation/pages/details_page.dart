import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vote_button.dart';
import '../../domain/entities/promo_code.dart';
import '../../domain/usecases/get_promo_code_by_id.dart';
import '../../domain/usecases/vote_promo_code.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/promo_code_provider.dart';

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
        const SnackBar(content: Text('Please sign in to vote')),
      );
      return;
    }

    if (_promoCode == null) return;

    final upvoteUseCase = ref.read(upvotePromoCodeProvider);
    final downvoteUseCase = ref.read(downvotePromoCodeProvider);
    final removeVoteUseCase = ref.read(removeVoteProvider);

    final isCurrentlyUpvoted = _promoCode!.upvotedBy.contains(currentUser.id);
    final isCurrentlyDownvoted = _promoCode!.downvotedBy.contains(currentUser.id);

    if (isUpvote) {
      if (isCurrentlyUpvoted) {
        await removeVoteUseCase(widget.promoCodeId, currentUser.id);
      } else {
        if (isCurrentlyDownvoted) {
          await removeVoteUseCase(widget.promoCodeId, currentUser.id);
        }
        await upvoteUseCase(widget.promoCodeId, currentUser.id);
      }
    } else {
      if (isCurrentlyDownvoted) {
        await removeVoteUseCase(widget.promoCodeId, currentUser.id);
      } else {
        if (isCurrentlyUpvoted) {
          await removeVoteUseCase(widget.promoCodeId, currentUser.id);
        }
        await downvoteUseCase(widget.promoCodeId, currentUser.id);
      }
    }

    _loadPromoCode();
  }

  void _sharePromoCode() {
    if (_promoCode != null) {
      Share.share(
        'Check out this promo code for ${_promoCode!.serviceName}: ${_promoCode!.code}',
      );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promo Code Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePromoCode,
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

            // Promo Code - Biggest
            Container(
              width: double.infinity,
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
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Author info
            if (promoCode.author != null)
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: promoCode.author!.photoUrl != null
                        ? NetworkImage(promoCode.author!.photoUrl!)
                        : null,
                    backgroundColor: theme.colorScheme.primary,
                    child: promoCode.author!.photoUrl == null
                        ? Text(
                            promoCode.author!.displayName?[0].toUpperCase() ?? 'U',
                            style: const TextStyle(color: AppColors.black),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promoCode.author!.displayName ?? 'Anonymous',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Karma: ${promoCode.author!.karma}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
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

            // Details
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

            // Vote section
            Center(
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
