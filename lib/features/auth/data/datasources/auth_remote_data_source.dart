import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import '../../../../core/errors/failures.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/domain/entities/user.dart' as app_user;

abstract class AuthRemoteDataSource {
  Future<app_user.User> signInAnonymously();
  Future<app_user.User> signInWithGoogle();
  Future<app_user.User> signInWithEmailAndPassword(
    String email,
    String password,
  );
  Future<app_user.User> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  );
  Future<void> signOut();
  Future<app_user.User?> getCurrentUser();
  Stream<app_user.User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore, this.googleSignIn);

  @override
  Future<app_user.User> signInAnonymously() async {
    try {
      print('🔵 Starting anonymous sign-in...');
      final credential = await firebaseAuth.signInAnonymously();
      print('🔵 Anonymous sign-in result: ${credential.user != null ? "Success" : "Failed"}');
      
      if (credential.user == null) {
        throw AuthFailure('Failed to sign in anonymously - no user returned');
      }
      
      print('🔵 Creating/getting user document...');
      return await _getOrCreateUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('🔴 Firebase Auth Error: ${e.code} - ${e.message}');
      throw AuthFailure('Anonymous sign-in failed: ${e.code} - ${e.message ?? "Unknown error"}');
    } catch (e, stackTrace) {
      print('🔴 Anonymous Sign-In Error: $e');
      print('🔴 Stack trace: $stackTrace');
      throw AuthFailure('Anonymous sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<app_user.User> signInWithGoogle() async {
    try {
      print('🔵 Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('🔵 Google Sign-In result: ${googleUser != null ? "Success" : "Cancelled"}');
      
      if (googleUser == null) {
        throw AuthFailure('Google sign in was cancelled');
      }

      print('🔵 Getting Google authentication...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('🔵 Creating Firebase credential...');
      
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔵 Signing in with Firebase credential...');
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw AuthFailure('Failed to sign in with Google - no user returned');
      }

      print('🔵 Creating/getting user document...');
      return await _getOrCreateUser(
        userCredential.user!,
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
    } on AuthFailure catch (e) {
      print('🔴 AuthFailure: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      print('🔴 Google Sign-In Error: $e');
      print('🔴 Stack trace: $stackTrace');
      throw AuthFailure('Google Sign-In failed: ${e.toString()}');
    }
  }

  @override
  Future<app_user.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthFailure('Failed to sign in');
      }
      return await _getOrCreateUser(credential.user!);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<app_user.User> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AuthFailure('Failed to sign up');
      }
      await credential.user!.updateDisplayName(displayName);
      return await _getOrCreateUser(credential.user!, displayName: displayName);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<app_user.User?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      return await _getOrCreateUser(user);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<app_user.User?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        return await _getOrCreateUser(firebaseUser);
      } catch (e) {
        return null;
      }
    });
  }

  Future<app_user.User> _getOrCreateUser(
    firebase_auth.User firebaseUser, {
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      print('🔵 Checking if user document exists...');
      final userDoc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      
      if (userDoc.exists) {
        print('🔵 User document found, returning existing user');
        return UserModel.fromFirestore(userDoc).toEntity();
      } else {
        print('🔵 Creating new user document...');
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: displayName ?? firebaseUser.displayName,
          photoUrl: photoUrl ?? firebaseUser.photoURL,
          karma: 0,
          createdAt: DateTime.now(),
        );
        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        print('✅ User document created successfully');
        return newUser.toEntity();
      }
    } on FirebaseException catch (e) {
      print('🔴 Firestore Error: ${e.code} - ${e.message}');
      if (e.code == 'unavailable' || e.message?.contains('NOT_FOUND') == true || e.message?.contains('does not exist') == true) {
        throw ServerFailure('Firestore database not created!\n\nCreate it at:\nhttps://console.firebase.google.com/project/arzan-a8f6d/firestore\n\nOr:\nhttps://console.cloud.google.com/datastore/setup?project=arzan-a8f6d');
      } else if (e.code == 'permission-denied') {
        throw ServerFailure('Firestore API not enabled. Enable it at: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=arzan-a8f6d');
      }
      throw ServerFailure('Firestore error: ${e.code} - ${e.message ?? "Unknown error"}');
    } catch (e, stackTrace) {
      print('🔴 Error creating/getting user: $e');
      print('🔴 Stack trace: $stackTrace');
      throw ServerFailure('Failed to create/get user: ${e.toString()}');
    }
  }
}
