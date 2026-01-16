# Create Firestore Database - Quick Fix

## The Problem:
Firestore API is enabled, but the **database itself doesn't exist yet**. You need to create it.

## Quick Fix:

### Option 1: Direct Link (Easiest)
Click this link to create the database:
https://console.cloud.google.com/datastore/setup?project=arzan-a8f6d

### Option 2: Via Firebase Console (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **arzan-a8f6d**
3. Click **Firestore Database** in the left menu
4. Click **"Create database"** button
5. Choose **"Start in test mode"** (for development)
6. Select a **location** (choose the closest to you, e.g., `us-central1` or `europe-west1`)
7. Click **"Enable"**

**Wait 1-2 minutes** for the database to be created.

### Option 3: Via Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **arzan-a8f6d**
3. Go to **Firestore** (or search for it)
4. Click **"Create database"**
5. Choose **Native mode** (not Datastore mode)
6. Select a location
7. Click **"Create"**

## After Creating:

1. Wait 1-2 minutes
2. Try signing in again
3. It should work now!

## Important:

- **Test mode** is fine for development (allows read/write)
- For production, you'll need to set up proper security rules
- The location you choose affects latency - pick the closest to your users
