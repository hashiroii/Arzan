import 'package:flutter/material.dart';
import '../../domain/repositories/promo_code_repository.dart';
import '../../../../core/utils/translations.dart';

class SortDropdown extends StatelessWidget {
  final Function(SortOption) onSortChanged;

  const SortDropdown({super.key, required this.onSortChanged});

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
        PopupMenuItem<SortOption>(
          value: SortOption.mostRecent,
          child: Text(Translations.mostRecent),
        ),
        PopupMenuItem<SortOption>(
          value: SortOption.publishTime,
          child: Text(Translations.publishTime),
        ),
        PopupMenuItem<SortOption>(
          value: SortOption.expirationDate,
          child: Text(Translations.expirationDateSort),
        ),
        PopupMenuItem<SortOption>(
          value: SortOption.alphabetical,
          child: Text(Translations.alphabetical),
        ),
        PopupMenuItem<SortOption>(
          value: SortOption.mostUpvoted,
          child: Text(Translations.mostUpvoted),
        ),
      ],
    );
  }
}
