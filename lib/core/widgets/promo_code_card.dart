import 'package:flutter/material.dart';
import '../../features/promo_codes/domain/entities/promo_code.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'vote_button.dart';

class PromoCodeCard extends StatelessWidget {
  final PromoCode promoCode;
  final VoidCallback? onTap;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;
  final String? currentUserId;

  const PromoCodeCard({
    super.key,
    required this.promoCode,
    this.onTap,
    this.onUpvote,
    this.onDownvote,
    this.currentUserId,
  });

  bool get isUpvoted =>
      currentUserId != null && promoCode.upvotedBy.contains(currentUserId!);
  bool get isDownvoted =>
      currentUserId != null && promoCode.downvotedBy.contains(currentUserId!);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = promoCode.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Service name and author
              Row(
                children: [
                  Expanded(
                    child: Text(
                      promoCode.serviceName,
                      style: AppTextStyles.h5.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (promoCode.author?.photoUrl != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        promoCode.author!.photoUrl!,
                      ),
                    )
                  else if (promoCode.author != null)
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        promoCode.author!.displayName?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(color: AppColors.black),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Promo Code - Biggest and most prominent
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    promoCode.code,
                    style: AppTextStyles.promoCode.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Comment
              if (promoCode.comment != null && promoCode.comment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    promoCode.comment!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Footer: Expiration date, votes, and action buttons
              Row(
                children: [
                  if (promoCode.expirationDate != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: isExpired
                                ? AppColors.error
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              isExpired
                                  ? 'Expired'
                                  : 'Expires ${_formatDate(promoCode.expirationDate!)}',
                              style: AppTextStyles.caption.copyWith(
                                color: isExpired
                                    ? AppColors.error
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        'No expiration',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),

                  VoteButton(
                    isUpvoted: isUpvoted,
                    isDownvoted: isDownvoted,
                    upvotes: promoCode.upvotes,
                    downvotes: promoCode.downvotes,
                    onUpvote: onUpvote != null ? () => onUpvote!() : null,
                    onDownvote: onDownvote != null ? () => onDownvote!() : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else {
      return 'Expired';
    }
  }
}
