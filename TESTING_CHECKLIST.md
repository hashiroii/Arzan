# Testing Checklist

## Before Testing

✅ Firebase is configured (`firebase_options.dart` exists)
✅ Dependencies are installed (`flutter pub get`)
✅ Firebase services are enabled in Firebase Console:
   - Authentication (Anonymous)
   - Firestore Database

## Firebase Console Setup

### 1. Enable Authentication
- Go to Firebase Console > Authentication > Sign-in method
- Enable **Anonymous** authentication

### 2. Create Firestore Database
- Go to Firebase Console > Firestore Database
- Click "Create database"
- Start in **test mode** (for development)
- Choose your preferred location

### 3. Set Firestore Security Rules

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

## Testing Steps

### 1. Run the App
```bash
flutter run
```

### 2. Test Authentication
- ✅ App should auto-sign in anonymously
- ✅ Check profile page shows user info
- ✅ Verify user document is created in Firestore

### 3. Test Promo Code Creation
- ✅ Tap the floating action button (+)
- ✅ Fill in service name, code, comment
- ✅ Set expiration date (optional)
- ✅ Submit and verify it appears in home feed

### 4. Test Voting System
- ✅ Upvote a promo code
- ✅ Downvote a promo code
- ✅ Remove vote by tapping again
- ✅ Verify vote counts update correctly

### 5. Test Filtering & Sorting
- ✅ Filter by service (Dodo Pizza, Fix Price, etc.)
- ✅ Test different sort options
- ✅ Verify filtered/sorted results display correctly

### 6. Test Details Page
- ✅ Tap on a promo code card
- ✅ View full details
- ✅ Test voting from details page
- ✅ Test share functionality

### 7. Test Profile Page
- ✅ View your profile
- ✅ Check karma display
- ✅ View your posted promo codes

### 8. Test Settings
- ✅ Change language (EN/RU)
- ✅ Change theme (Light/Dark/System)
- ✅ Request notification permission
- ✅ View app version

### 9. Test Infinite Scroll
- ✅ Scroll down to load more promo codes
- ✅ Verify pagination works correctly

## Common Issues & Solutions

### Issue: "Permission denied" errors
**Solution**: Check Firestore security rules are set correctly

### Issue: App crashes on startup
**Solution**: 
- Verify `firebase_options.dart` exists
- Check Firebase services are enabled
- Run `flutter clean` and `flutter pub get`

### Issue: No promo codes showing
**Solution**: 
- Check Firestore has data
- Verify authentication is working
- Check console for errors

### Issue: Votes not updating
**Solution**: 
- Check Firestore rules allow updates
- Verify user is authenticated
- Check network connection

## Next Steps After Testing

1. **Add Sample Data**: Create some test promo codes
2. **Test Edge Cases**: Expired codes, empty lists, etc.
3. **Performance**: Test with many promo codes
4. **Production Setup**: 
   - Update Firestore security rules for production
   - Set up proper indexes
   - Configure Firebase Analytics (optional)
   - Set up Google Ads (for banner)

## Firebase Indexes Needed

When you start filtering/sorting, Firebase may prompt you to create indexes. Create these:

1. **promoCodes** collection:
   - `serviceName` (Ascending) + `publishDate` (Descending)
   - `serviceName` (Ascending) + `expirationDate` (Ascending)
   - `serviceName` (Ascending) + `upvotes` (Descending)

These will be created automatically when needed, or you can create them manually in Firebase Console > Firestore > Indexes.
