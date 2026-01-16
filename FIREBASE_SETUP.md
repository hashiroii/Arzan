# Firebase Setup Guide

This guide will help you set up Firebase for the Arzan app.

## Prerequisites

1. A Firebase project created at [Firebase Console](https://console.firebase.google.com/)
2. FlutterFire CLI installed: `dart pub global activate flutterfire_cli`

## Setup Steps

### 1. Install FlutterFire CLI (if not already installed)

```bash
dart pub global activate flutterfire_cli
```

### 2. Configure Firebase for your Flutter app

Run the following command in your project root:

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select the project
- Configure Firebase for all platforms (iOS, Android, Web, etc.)
- Generate `firebase_options.dart` file

### 3. Enable Firebase Services

In the Firebase Console, enable the following services:

#### Authentication
1. Go to **Authentication** > **Sign-in method**
2. Enable **Anonymous** authentication (for guest users)
3. Enable **Email/Password** authentication (optional, for registered users)

#### Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **test mode** (for development)
4. Choose your preferred location

#### Firestore Security Rules

Update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // PromoCodes collection
    match /promoCodes/{promoCodeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && 
        resource.data.authorId == request.auth.uid;
    }
  }
}
```

### 4. Firestore Indexes

Create the following composite indexes in Firestore:

1. **promoCodes collection:**
   - Fields: `serviceName` (Ascending), `publishDate` (Descending)
   - Fields: `serviceName` (Ascending), `expirationDate` (Ascending)
   - Fields: `serviceName` (Ascending), `upvotes` (Descending)

You can create indexes manually in Firebase Console under **Firestore** > **Indexes**, or Firebase will prompt you to create them when you run queries.

### 5. Update firebase_options.dart import

After running `flutterfire configure`, update the import in `lib/core/utils/dependency_injection.dart`:

```dart
import 'firebase_options.dart'; // Add this import
```

And update the initialization:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 6. Platform-specific Setup

#### Android
- The `google-services.json` file should be automatically added to `android/app/`
- Update `android/app/build.gradle` to include the Google Services plugin

#### iOS
- The `GoogleService-Info.plist` file should be automatically added to `ios/Runner/`
- Make sure CocoaPods are installed and run `pod install` in the `ios/` directory

### 7. Test the Connection

Run the app and verify:
- Anonymous authentication works
- Firestore connection is established
- You can create and read promo codes

## Troubleshooting

### Firebase not initialized
- Make sure `firebase_options.dart` exists and is properly configured
- Check that Firebase is initialized before any Firebase calls

### Permission denied errors
- Verify Firestore security rules are correctly set
- Check that authentication is working

### Build errors
- Run `flutter clean` and `flutter pub get`
- For iOS: Run `pod install` in the `ios/` directory
- For Android: Clean and rebuild the project

## Next Steps

After Firebase is set up:
1. Test creating a promo code
2. Test voting functionality
3. Test user profile creation
4. Set up proper Firestore indexes for production
5. Review and tighten security rules for production
