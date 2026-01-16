# Enable Firestore API - Quick Fix

## The Problem:
Your Google Sign-In is working! But Firestore API is not enabled, so it can't save user data.

## Quick Fix:

### Option 1: Direct Link (Easiest)
Click this link to enable Firestore API:
https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=arzan-a8f6d

Click **"Enable"** button.

### Option 2: Manual Steps
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **arzan-a8f6d**
3. Go to **APIs & Services** → **Library**
4. Search for **"Cloud Firestore API"**
5. Click on it
6. Click **"Enable"**

## After Enabling:
1. Wait 1-2 minutes for the API to propagate
2. Try Google Sign-In again
3. It should work now!

## Also Fix Anonymous Sign-In:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **arzan-a8f6d**
3. Go to **Authentication** → **Sign-in method**
4. Click **Anonymous**
5. Make sure it's **Enabled**
6. If you see any restrictions, remove them
7. Click **Save**

## That's It!
After enabling Firestore API, Google Sign-In should work completely!
