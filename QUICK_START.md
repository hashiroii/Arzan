# Quick Start Guide

## Before Running the App

### 1. Set Up Firebase

**Important**: You must set up Firebase before running the app.

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase:
   ```bash
   flutterfire configure
   ```

3. Follow the prompts to select your Firebase project

4. After configuration, update `lib/core/utils/dependency_injection.dart`:
   - Uncomment the `firebase_options.dart` import
   - Uncomment the `DefaultFirebaseOptions.currentPlatform` in `Firebase.initializeApp()`

5. Enable Firebase services in Firebase Console:
   - **Authentication**: Enable Anonymous auth
   - **Firestore**: Create database in test mode
   - Set up security rules (see FIREBASE_SETUP.md)

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Project Structure Overview

- **lib/core/**: Core utilities, theme, constants
- **lib/features/**: Feature modules (auth, promo_codes, user)
- **assets/translations/**: Localization files

## Key Features Implemented

✅ Clean Architecture with MVVM
✅ Firebase integration (Auth + Firestore)
✅ Promo code CRUD operations
✅ Voting system (upvote/downvote)
✅ Karma system
✅ User profiles
✅ Settings page
✅ Dark/Light themes
✅ Multi-language support (EN/RU)
✅ Infinite scroll pagination
✅ Filtering and sorting
✅ Beautiful coupon-like UI

## Next Steps

1. **Complete Firebase Setup**: Follow FIREBASE_SETUP.md
2. **Test the App**: Create promo codes, vote, test all features
3. **Customize**: Update colors, add more services, customize UI
4. **Add Features**: Implement Google Ads in banner, add more languages
5. **Production**: Set up proper Firestore indexes and security rules

## Troubleshooting

### App crashes on startup
- Make sure Firebase is configured (`flutterfire configure`)
- Check that `firebase_options.dart` exists
- Verify Firebase services are enabled in Firebase Console

### "Permission denied" errors
- Check Firestore security rules
- Verify authentication is working

### Build errors
- Run `flutter clean`
- Run `flutter pub get`
- For iOS: `cd ios && pod install`
