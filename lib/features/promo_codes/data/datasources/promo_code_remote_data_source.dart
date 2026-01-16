import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/failures.dart';
import '../models/promo_code_model.dart';
import '../../domain/repositories/promo_code_repository.dart';

abstract class PromoCodeRemoteDataSource {
  Future<List<PromoCodeModel>> getPromoCodes({
    String? serviceFilter,
    SortOption sortOption = SortOption.mostRecent,
    int limit = 20,
    String? lastDocumentId,
  });

  Future<PromoCodeModel> getPromoCodeById(String id);

  Future<PromoCodeModel> createPromoCode(PromoCodeModel promoCode);

  Future<void> upvotePromoCode(String promoCodeId, String userId);

  Future<void> downvotePromoCode(String promoCodeId, String userId);

  Future<void> removeVote(String promoCodeId, String userId);

  Future<List<PromoCodeModel>> getUserPromoCodes(String userId);

  Future<void> deletePromoCode(String promoCodeId, String userId);
}

class PromoCodeRemoteDataSourceImpl implements PromoCodeRemoteDataSource {
  final FirebaseFirestore firestore;

  PromoCodeRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<PromoCodeModel>> getPromoCodes({
    String? serviceFilter,
    SortOption sortOption = SortOption.mostRecent,
    int limit = 20,
    String? lastDocumentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore.collection('promoCodes');

      // Apply service filter
      if (serviceFilter != null && serviceFilter.isNotEmpty) {
        query = query.where('serviceName', isEqualTo: serviceFilter);
      }

      // Apply sorting
      switch (sortOption) {
        case SortOption.publishTime:
          query = query.orderBy('publishDate', descending: true);
          break;
        case SortOption.expirationDate:
          query = query.orderBy('expirationDate', descending: false);
          break;
        case SortOption.alphabetical:
          query = query.orderBy('serviceName', descending: false);
          break;
        case SortOption.mostUpvoted:
          query = query.orderBy('upvotes', descending: true);
          break;
        case SortOption.mostRecent:
        default:
          query = query.orderBy('publishDate', descending: true);
          break;
      }

      // Apply pagination
      if (lastDocumentId != null) {
        final lastDoc = await firestore.collection('promoCodes').doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PromoCodeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PromoCodeModel> getPromoCodeById(String id) async {
    try {
      final doc = await firestore.collection('promoCodes').doc(id).get();
      if (!doc.exists) {
        throw ServerFailure('Promo code not found');
      }
      return PromoCodeModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PromoCodeModel> createPromoCode(PromoCodeModel promoCode) async {
    try {
      final docRef = firestore.collection('promoCodes').doc();
      final data = promoCode.toFirestore();
      await docRef.set(data);
      return PromoCodeModel(
        id: docRef.id,
        code: promoCode.code,
        serviceName: promoCode.serviceName,
        authorId: promoCode.authorId,
        comment: promoCode.comment,
        publishDate: promoCode.publishDate,
        expirationDate: promoCode.expirationDate,
        upvotes: promoCode.upvotes,
        downvotes: promoCode.downvotes,
        upvotedBy: promoCode.upvotedBy,
        downvotedBy: promoCode.downvotedBy,
        isActive: promoCode.isActive,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> upvotePromoCode(String promoCodeId, String userId) async {
    try {
      final docRef = firestore.collection('promoCodes').doc(promoCodeId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw ServerFailure('Promo code not found');
      }

      final data = doc.data()!;
      final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(data['downvotedBy'] ?? []);

      // Remove from downvotes if exists
      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await docRef.update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': downvotedBy,
        });
      }

      // Add to upvotes if not already there
      if (!upvotedBy.contains(userId)) {
        upvotedBy.add(userId);
        await docRef.update({
          'upvotes': FieldValue.increment(1),
          'upvotedBy': upvotedBy,
        });
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> downvotePromoCode(String promoCodeId, String userId) async {
    try {
      final docRef = firestore.collection('promoCodes').doc(promoCodeId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw ServerFailure('Promo code not found');
      }

      final data = doc.data()!;
      final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(data['downvotedBy'] ?? []);

      // Remove from upvotes if exists
      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await docRef.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': upvotedBy,
        });
      }

      // Add to downvotes if not already there
      if (!downvotedBy.contains(userId)) {
        downvotedBy.add(userId);
        await docRef.update({
          'downvotes': FieldValue.increment(1),
          'downvotedBy': downvotedBy,
        });
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> removeVote(String promoCodeId, String userId) async {
    try {
      final docRef = firestore.collection('promoCodes').doc(promoCodeId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw ServerFailure('Promo code not found');
      }

      final data = doc.data()!;
      final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(data['downvotedBy'] ?? []);

      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await docRef.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': upvotedBy,
        });
      }

      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await docRef.update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': downvotedBy,
        });
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<PromoCodeModel>> getUserPromoCodes(String userId) async {
    try {
      final snapshot = await firestore
          .collection('promoCodes')
          .where('authorId', isEqualTo: userId)
          .orderBy('publishDate', descending: true)
          .get();

      return snapshot.docs.map((doc) => PromoCodeModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deletePromoCode(String promoCodeId, String userId) async {
    try {
      final doc = await firestore.collection('promoCodes').doc(promoCodeId).get();
      if (!doc.exists) {
        throw ServerFailure('Promo code not found');
      }
      if (doc.data()!['authorId'] != userId) {
        throw ServerFailure('Unauthorized');
      }
      await firestore.collection('promoCodes').doc(promoCodeId).delete();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
