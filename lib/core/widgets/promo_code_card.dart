import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/promo_codes/domain/entities/promo_code.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../data/services_data.dart';
import '../utils/translations.dart';

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
      !promoCode.downvotedBy.contains(currentUserId!); // Ensure mutual exclusivity
  bool get isDownvoted =>
      currentUserId != null && 
      promoCode.downvotedBy.contains(currentUserId!) &&
      !promoCode.upvotedBy.contains(currentUserId!); // Ensure mutual exclusivity

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = promoCode.isExpired;
    final karma = promoCode.karma;

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
              // Header: Service logo, service name, and credibility (karma) on top right
              Row(
                children: [
                  // Service logo on left
                  Builder(
                    builder: (context) {
                      final service = ServicesData.getServiceByName(promoCode.serviceName);
                      if (service != null && service.logoUrl.isNotEmpty) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: CachedNetworkImage(
                              imageUrl: service.logoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: theme.colorScheme.primaryContainer,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: theme.colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.store,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            promoCode.serviceName.isNotEmpty
                                ? promoCode.serviceName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promoCode.serviceName,
                          style: AppTextStyles.h5.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (promoCode.author != null)
                          Text(
                            'by ${promoCode.author!.displayName ?? 'Anonymous'}',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Credibility (Karma) badge on top right
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          karma.toString(),
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Promo Code with Copy Button
              Row(
                children: [
                  Expanded(
                    child: Container(
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
                            color: AppColors
                                .black, // Black text for better visibility on yellow
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
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
                  ),
                ],
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

              // Footer: Expiration date and vote buttons (next to each other)
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
                                  ? Translations.expired
                                  : '${Translations.expires} ${_formatDate(promoCode.expirationDate!)}',
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
                        Translations.noExpiration,
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upvote button
                      InkWell(
                        onTap: onUpvote,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUpvoted
                                ? AppColors.upvote.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                size: 20,
                                color: isUpvoted
                                    ? AppColors.upvote
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                promoCode.upvotes.toString(),
                                style: AppTextStyles.caption.copyWith(
                                  color: isUpvoted
                                      ? AppColors.upvote
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                                  fontWeight: isUpvoted
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Downvote button
                      InkWell(
                        onTap: onDownvote,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDownvoted
                                ? AppColors.downvote.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                size: 20,
                                color: isDownvoted
                                    ? AppColors.downvote
                                    : theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                promoCode.downvotes.toString(),
                                style: AppTextStyles.caption.copyWith(
                                  color: isDownvoted
                                      ? AppColors.downvote
                                      : theme.colorScheme.onSurface.withOpacity(
                                          0.6,
                                        ),
                                  fontWeight: isDownvoted
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
