import 'package:flutter/material.dart';
import '../../../../core/data/services_data.dart';
import '../../../../core/utils/translations.dart';

class ServiceSelectorWidget extends StatelessWidget {
  final String? selectedService;
  final Function(String?) onServiceChanged;
  final bool showAllOption;

  const ServiceSelectorWidget({
    super.key,
    this.selectedService,
    required this.onServiceChanged,
    this.showAllOption = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return DropdownButtonFormField<String>(
      value: selectedService,
      decoration: InputDecoration(
        labelText: Translations.service,
        hintText: Translations.allServices,
        prefixIcon: const Icon(Icons.store),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: [
        if (showAllOption)
          DropdownMenuItem<String>(
            value: null,
            child: Text(Translations.allServices),
          ),
        ...ServicesData.services.map((service) {
          return DropdownMenuItem<String>(
            value: service.name,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.store,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(service.name),
              ],
            ),
          );
        }),
      ],
      onChanged: onServiceChanged,
    );
  }
}
