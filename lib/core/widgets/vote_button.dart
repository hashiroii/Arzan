import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class VoteButton extends StatelessWidget {
  final bool isUpvoted;
  final bool isDownvoted;
  final int upvotes;
  final int downvotes;
  final VoidCallback? onUpvote;
  final VoidCallback? onDownvote;

  const VoteButton({
    super.key,
    this.isUpvoted = false,
    this.isDownvoted = false,
    required this.upvotes,
    required this.downvotes,
    this.onUpvote,
    this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final karma = upvotes - downvotes;

    return Row(
      children: [
        InkWell(
          onTap: onUpvote,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUpvoted
                  ? AppColors.upvote.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 20,
                  color: isUpvoted
                      ? AppColors.upvote
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  upvotes.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isUpvoted
                        ? AppColors.upvote
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isUpvoted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            karma.toString(),
            style: AppTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),

        InkWell(
          onTap: onDownvote,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDownvoted
                  ? AppColors.downvote.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 20,
                  color: isDownvoted
                      ? AppColors.downvote
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  downvotes.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isDownvoted
                        ? AppColors.downvote
                        : theme.colorScheme.onSurface.withOpacity(0.6),
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
    );
  }
}
