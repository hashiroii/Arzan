# How to Add SHA Fingerprints to Firebase (Step-by-Step)

## Why You Need This:
Error code 10 (DEVELOPER_ERROR) means Google Sign-In can't verify your app. Adding SHA fingerprints fixes this.

## Your SHA Fingerprints (Already Generated):

**SHA-1:**
```
54:47:A6:75:A7:CF:31:4A:E6:54:3A:26:B1:C5:42:A8:E5:0F:9B:0C
```

**SHA-256:**
```
6D:E9:F8:E2:32:C9:8C:74:25:F0:80:EE:09:02:AD:21:2B:43:6E:51:72:CF:36:0C:DA:7F:AD:3F:D9:18:28:2C
```

## Step-by-Step Instructions:

### 1. Go to Firebase Console
- Open: https://console.firebase.google.com/
- Select your project: **arzan-a8f6d**

### 2. Navigate to Project Settings
- Click the **gear icon** (⚙️) next to "Project Overview" at the top left
- Click **Project settings**

### 3. Find Your Android App
- Scroll down to the **"Your apps"** section
- You should see your Android app: `com.example.arzan`
- Click on it (or the Android icon)

### 4. Add SHA-1 Fingerprint
- Look for **"SHA certificate fingerprints"** section
- Click **"Add fingerprint"** button
- Paste this SHA-1:
  ```
  54:47:A6:75:A7:CF:31:4A:E6:54:3A:26:B1:C5:42:A8:E5:0F:9B:0C
  ```
- Click **Save**

### 5. Add SHA-256 Fingerprint
- Click **"Add fingerprint"** button again
- Paste this SHA-256:
  ```
  6D:E9:F8:E2:32:C9:8C:74:25:F0:80:EE:09:02:AD:21:2B:43:6E:51:72:CF:36:0C:DA:7F:AD:3F:D9:18:28:2C
  ```
- Click **Save**

### 6. Download Updated google-services.json
- After adding both fingerprints, you'll see a **"Download google-services.json"** button
- Click it to download the new file
- **Important:** Replace the old file at: `android/app/google-services.json`

### 7. Rebuild Your App
```bash
flutter clean
flutter pub get
flutter run
```

## Verification:

After adding fingerprints and downloading the new google-services.json, check that it has OAuth client entries:

```bash
cat android/app/google-services.json | grep -A 5 "oauth_client"
```

You should see entries with `client_id` values, not an empty array `[]`.

## Still Not Working?

1. **Wait 5-10 minutes** - Firebase sometimes takes time to propagate changes
2. **Make sure you downloaded the NEW google-services.json** after adding fingerprints
3. **Do a full rebuild**: `flutter clean && flutter pub get && flutter run`
4. **Check Firebase Console** - Make sure both SHA-1 and SHA-256 are listed
