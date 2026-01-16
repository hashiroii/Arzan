import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/domain/entities/user.dart' as app_user;

abstract class AuthRemoteDataSource {
  Future<app_user.User> signInAnonymously();
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

  AuthRemoteDataSourceImpl(this.firebaseAuth, this.firestore);

  @override
  Future<app_user.User> signInAnonymously() async {
    try {
      final credential = await firebaseAuth.signInAnonymously();
      if (credential.user == null) {
        throw AuthFailure('Failed to sign in anonymously');
      }
      return await _getOrCreateUser(credential.user!);
    } catch (e) {
      throw AuthFailure(e.toString());
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
      await firebaseAuth.signOut();
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
  }) async {
    try {
      final userDoc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc).toEntity();
      } else {
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: displayName ?? firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          karma: 0,
          createdAt: DateTime.now(),
        );
        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toFirestore());
        return newUser.toEntity();
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
