# Arzan - Promo Code Sharing App

An enterprise-level Flutter application for sharing and discovering promo codes with a karma-based reputation system.

## Features

- 🎫 **Promo Code Sharing**: Share promo codes from various services
- ⬆️⬇️ **Voting System**: Upvote/downvote promo codes to ensure quality
- ⭐ **Karma System**: User credibility based on community feedback
- 🎨 **Beautiful UI**: Modern, coupon-like design with dark/light themes
- 🌍 **Multi-language**: English and Russian support
- 🔍 **Filtering & Sorting**: Filter by service, sort by various criteria
- 👤 **User Profiles**: View user karma and their posted codes
- ⚙️ **Settings**: Customize theme, language, and account settings

## Architecture

The app follows **Clean Architecture** principles with:

- **Domain Layer**: Entities, Use Cases, Repository Interfaces
- **Data Layer**: Repository Implementations, Data Sources, Models
- **Presentation Layer**: Pages, Widgets, Providers (Riverpod)

### Key Patterns

- **MVVM**: ViewModels implemented using Riverpod StateNotifiers
- **Repository Pattern**: Abstraction between data sources and business logic
- **Use Cases**: Single responsibility business logic operations
- **Dependency Injection**: Centralized dependency management

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants
│   ├── errors/          # Failure classes
│   ├── providers/       # Global providers (theme, locale)
│   ├── theme/           # Design system (colors, text styles, themes)
│   ├── utils/           # Utilities (DI, helpers)
│   └── widgets/         # Reusable widgets
├── features/
│   ├── auth/            # Authentication feature
│   ├── promo_codes/     # Promo codes feature
│   └── user/            # User feature
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Firebase project (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase (see [FIREBASE_SETUP.md](FIREBASE_SETUP.md))

4. Run the app:
   ```bash
   flutter run
   ```

## Firebase Setup

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed Firebase configuration instructions.

## Key Pages

1. **Home Page**: Browse promo codes with filtering and sorting
2. **Details Page**: View full promo code details
3. **Post Page**: Create new promo codes
4. **Profile Page**: View user profile and karma
5. **Settings Page**: App settings and preferences

## Design System

The app uses a centralized design system:

- **Primary Color**: Yellow (#FFD700)
- **Theme Support**: Light, Dark, System default
- **Typography**: Consistent text styles defined in `app_text_styles.dart`
- **Colors**: Centralized color palette in `app_colors.dart`

All UI components can be customized from the core theme files.

## State Management

The app uses **Riverpod** for state management:

- `StateNotifierProvider` for complex state
- `Provider` for simple values and dependencies
- `StreamProvider` for reactive data (auth state)

## Dependencies

Key dependencies:

- `flutter_riverpod`: State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase backend
- `cached_network_image`: Image caching
- `carousel_slider`: Banner carousel
- `share_plus`: Share functionality
- `package_info_plus`: App version info
- `permission_handler`: Permission management

## Contributing

This is an enterprise-level application. When contributing:

1. Follow Clean Architecture principles
2. Write tests for use cases and repositories
3. Maintain consistent code style
4. Update documentation

## License

[Your License Here]

## Support

For issues and questions, please open an issue on the repository.
