# Firebase Authentication Setup - Quick Fix

## Current Errors:
- Google Sign-In: `ApiException: 10` (DEVELOPER_ERROR)
- Anonymous Sign-In: `CONFIGURATION_NOT_FOUND`

## Quick Fix Steps:

### 1. Enable Anonymous Authentication (Easiest - Do This First!)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **arzan-a8f6d**
3. Go to **Authentication** → **Sign-in method**
4. Find **Anonymous** in the list
5. Click on it and **Enable**
6. Click **Save**

**That's it!** Now the "Continue as Guest" button will work.

### 2. Enable Google Sign-In (For Google Login)

1. In Firebase Console → **Authentication** → **Sign-in method**
2. Find **Google** in the list
3. Click on it and **Enable**
4. Set a **Support email** (your email)
5. Click **Save**

### 3. Add SHA Fingerprints (Required for Google Sign-In)

You need to add your app's SHA-1 and SHA-256 fingerprints:

#### Get SHA Fingerprints:

**On macOS/Linux:**
```bash
cd android
./gradlew signingReport
```

Look for lines like:
```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

**Or use keytool directly:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### Add to Firebase:

1. Go to Firebase Console → **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Click on your Android app (`com.example.arzan`)
4. Click **Add fingerprint**
5. Paste your **SHA-1** fingerprint → **Save**
6. Click **Add fingerprint** again
7. Paste your **SHA-256** fingerprint → **Save**

### 4. Download Updated google-services.json

1. After adding fingerprints, click **Download google-services.json**
2. Replace the file at: `android/app/google-services.json`
3. Rebuild the app: `flutter clean && flutter run`

## Test:

1. **Anonymous Sign-In**: Should work immediately after enabling in Firebase Console
2. **Google Sign-In**: Should work after adding SHA fingerprints and downloading new google-services.json

## Common Issues:

- **Still getting errors?** Make sure you:
  - Enabled the sign-in method in Firebase Console
  - For Google: Added SHA fingerprints AND downloaded new google-services.json
  - Rebuilt the app after changes
