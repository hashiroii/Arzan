import 'package:flutter/material.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../../../../core/constants/app_constants.dart';

class SortDropdown extends StatelessWidget {
  final Function(SortOption) onSortChanged;

  const SortDropdown({
    super.key,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    SortOption _currentSort = SortOption.mostRecent;

    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      onSelected: (SortOption sort) {
        _currentSort = sort;
        onSortChanged(sort);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
        const PopupMenuItem<SortOption>(
          value: SortOption.mostRecent,
          child: Text('Most Recent'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.publishTime,
          child: Text('Publish Time'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.expirationDate,
          child: Text('Expiration Date'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.alphabetical,
          child: Text('Alphabetical'),
        ),
        const PopupMenuItem<SortOption>(
          value: SortOption.mostUpvoted,
          child: Text('Most Upvoted'),
        ),
      ],
    );
  }
}
