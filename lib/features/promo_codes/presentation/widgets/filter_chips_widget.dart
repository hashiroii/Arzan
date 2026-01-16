import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class FilterChipsWidget extends StatefulWidget {
  final Function(String?) onFilterChanged;

  const FilterChipsWidget({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<FilterChipsWidget> createState() => _FilterChipsWidgetState();
}

class _FilterChipsWidgetState extends State<FilterChipsWidget> {
  String? _selectedService;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleServices = _isExpanded
        ? AppConstants.popularServices
        : AppConstants.popularServices.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...visibleServices.map((service) {
              final isSelected = _selectedService == service;
              return FilterChip(
                label: Text(service),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedService = selected ? service : null;
                  });
                  widget.onFilterChanged(_selectedService);
                },
                selectedColor: AppColors.primaryYellow.withOpacity(0.3),
                checkmarkColor: AppColors.black,
              );
            }),
            if (AppConstants.popularServices.length > 3)
              FilterChip(
                label: Text(_isExpanded ? 'Less' : 'More'),
                onSelected: (selected) {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                avatar: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
