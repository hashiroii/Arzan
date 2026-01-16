# Google Sign-In Setup Guide

## Issue
If you're seeing errors when trying to sign in with Google, it's likely because Google Sign-In is not properly configured in Firebase Console.

## Steps to Fix

### 1. Enable Google Sign-In in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`arzan-a8f6d`)
3. Go to **Authentication** > **Sign-in method**
4. Click on **Google**
5. Enable it and set a support email
6. Click **Save**

### 2. Add SHA-1 and SHA-256 Fingerprints

You need to add your app's SHA fingerprints to Firebase:

#### Get Debug SHA-1 Fingerprint:
```bash
cd android
./gradlew signingReport
```

Look for `SHA1:` in the output, or use:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Get SHA-256 Fingerprint:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA256
```

### 3. Add Fingerprints to Firebase

1. Go to Firebase Console > Project Settings
2. Scroll down to **Your apps** section
3. Click on your Android app
4. Click **Add fingerprint**
5. Add both SHA-1 and SHA-256 fingerprints

### 4. Download Updated google-services.json

1. After adding fingerprints, download the updated `google-services.json`
2. Replace the file in `android/app/google-services.json`

### 5. Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Use Anonymous Sign-In for Testing

If you want to test the app without setting up Google Sign-In immediately, you can temporarily enable anonymous sign-in:

1. Go to Firebase Console > Authentication > Sign-in method
2. Enable **Anonymous**
3. Update the login page to show an "Continue as Guest" button

## Common Errors

- **DEVELOPER_ERROR (10:)**: OAuth client not configured - follow steps above
- **12500**: App not found - check package name matches Firebase
- **Sign in cancelled**: User cancelled the sign-in (not an error)

## Verification

After setup, the `google-services.json` file should have entries in the `oauth_client` array, not an empty array.
