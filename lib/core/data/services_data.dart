class Service {
  final String id;
  final String name;
  final String logoUrl; // For now, we'll use a placeholder or asset path
  final List<String> aliases; // Alternative names for smart search

  const Service({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.aliases = const [],
  });
}

class ServicesData {
  ServicesData._();

  static const List<Service> services = [
    Service(
      id: 'dodo_pizza',
      name: 'Dodo Pizza',
      logoUrl: '', // Will use icon fallback
      aliases: ['dodo', 'pizza dodo', 'додо пицца', 'dodo pizza'],
    ),
    Service(
      id: 'airba_fresh',
      name: 'Airba Fresh',
      logoUrl: '', // Will use icon fallback
      aliases: ['airba', 'fresh', 'эйрба фреш', 'airba fresh'],
    ),
    Service(
      id: 'arbuz',
      name: 'Arbuz',
      logoUrl: '', // Will use icon fallback
      aliases: ['арбуз', 'arbuz'],
    ),
    Service(
      id: 'yandex_go',
      name: 'Yandex Go',
      logoUrl: '', // Will use icon fallback
      aliases: ['yandex', 'яндекс го', 'яндекс такси', 'yandex go', 'yandex taxi'],
    ),
    Service(
      id: 'chocofood',
      name: 'Chocofood',
      logoUrl: '', // Will use icon fallback
      aliases: ['choco', 'чокофуд', 'chocofood'],
    ),
    Service(
      id: 'fix_price',
      name: 'Fix Price',
      logoUrl: '', // Will use icon fallback
      aliases: ['fixprice', 'фикс прайс', 'фикспрайс', 'fix price'],
    ),
  ];

  // Smart search - finds services by name or alias
  static List<Service> searchServices(String query) {
    if (query.isEmpty) return services;

    final lowerQuery = query.toLowerCase().trim();
    return services.where((service) {
      // Check if query matches service name
      if (service.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // Check if query matches any alias
      if (service.aliases.any((alias) => alias.toLowerCase().contains(lowerQuery))) {
        return true;
      }
      // Check if any word in query matches
      final queryWords = lowerQuery.split(' ');
      return queryWords.any((word) =>
          service.name.toLowerCase().contains(word) ||
          service.aliases.any((alias) => alias.toLowerCase().contains(word)));
    }).toList();
  }

  static Service? getServiceByName(String name) {
    if (name.isEmpty) return null;
    final lowerName = name.toLowerCase().trim();
    
    // Try exact match first
    for (final service in services) {
      if (service.name.toLowerCase() == lowerName) {
        return service;
      }
    }
    
    // Try partial match
    for (final service in services) {
      if (service.name.toLowerCase().contains(lowerName) ||
          lowerName.contains(service.name.toLowerCase())) {
        return service;
      }
    }
    
    // Try alias match
    for (final service in services) {
      for (final alias in service.aliases) {
        if (alias.toLowerCase() == lowerName ||
            lowerName.contains(alias.toLowerCase()) ||
            alias.toLowerCase().contains(lowerName)) {
          return service;
        }
      }
    }
    
    return null;
  }

  static Service? getServiceById(String id) {
    try {
      return services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }
}
