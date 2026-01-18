import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/promo_codes/domain/entities/promo_code.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/services_data.dart';

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
      currentUserId != null && 
      promoCode.upvotedBy.contains(currentUserId!) &&
      !promoCode.downvotedBy.contains(currentUserId!);
  bool get isDownvoted =>
      currentUserId != null && 
      promoCode.downvotedBy.contains(currentUserId!) &&
      !promoCode.upvotedBy.contains(currentUserId!);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = promoCode.isExpired;
    final karma = promoCode.karma;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        final service = ServicesData.getServiceByName(
                          promoCode.serviceName,
                        );
                        if (service != null && service.logoUrl.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: CachedNetworkImage(
                              imageUrl: service.logoUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.store,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: Text(
                            promoCode.serviceName.isNotEmpty
                                ? promoCode.serviceName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
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
                                promoCode.serviceName,
                                style: AppTextStyles.h5.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    karma.toString(),
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (promoCode.author != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'by ${promoCode.author!.displayName ?? 'Anonymous'}',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.primaryContainer.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    promoCode.code,
                    style: AppTextStyles.promoCode.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              if (promoCode.comment != null && promoCode.comment!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    promoCode.comment!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (promoCode.expirationDate != null)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18,
                            color: isExpired
                                ? AppColors.error
                                : theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              isExpired
                                  ? 'Expired'
                                  : 'Expires ${_formatDate(promoCode.expirationDate!)}',
                              style: AppTextStyles.caption.copyWith(
                                color: isExpired
                                    ? AppColors.error
                                    : theme.colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.all_inclusive,
                            size: 18,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'No expiration',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 12),
                  _VoteButton(
                    icon: Icons.arrow_upward,
                    count: promoCode.upvotes,
                    isActive: isUpvoted,
                    color: AppColors.upvote,
                    onTap: onUpvote,
                  ),
                  const SizedBox(width: 8),
                  _VoteButton(
                    icon: Icons.arrow_downward,
                    count: promoCode.downvotes,
                    isActive: isDownvoted,
                    color: AppColors.downvote,
                    onTap: onDownvote,
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

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final Color color;
  final VoidCallback? onTap;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(color: color.withOpacity(0.3), width: 1.5)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? color
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: AppTextStyles.caption.copyWith(
                  color: isActive
                      ? color
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

