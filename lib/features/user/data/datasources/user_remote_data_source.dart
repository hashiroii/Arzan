import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getCurrentUser(String userId);
  Future<UserModel> getUserById(String userId);
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  Future<void> updateUserKarma(String userId, int karmaChange);
  Future<void> recalculateUserKarma(String userId, int totalKarma);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl(this.firestore);

  @override
  Future<UserModel> getCurrentUser(String userId) async {
    return getUserById(userId);
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw ServerFailure('User not found');
      }
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final data = user.toFirestore();
      await firestore.collection('users').doc(user.id).update(data);
      return user;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateUserKarma(String userId, int karmaChange) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'karma': FieldValue.increment(karmaChange),
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> recalculateUserKarma(String userId, int totalKarma) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'karma': totalKarma,
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
