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

      if (serviceFilter != null && serviceFilter.isNotEmpty) {
        query = query.where('serviceName', isEqualTo: serviceFilter);
      } else {
        switch (sortOption) {
          case SortOption.publishTime:
          case SortOption.mostRecent:
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
        }
      }

      if (lastDocumentId != null && (serviceFilter == null || serviceFilter.isEmpty)) {
        final lastDoc = await firestore.collection('promoCodes').doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      var models = snapshot.docs.map((doc) => PromoCodeModel.fromFirestore(doc)).toList();
      
      if (serviceFilter != null && serviceFilter.isNotEmpty) {
        switch (sortOption) {
          case SortOption.publishTime:
          case SortOption.mostRecent:
            models.sort((a, b) => b.publishDate.compareTo(a.publishDate));
            break;
          case SortOption.expirationDate:
            models.sort((a, b) {
              if (a.expirationDate == null && b.expirationDate == null) return 0;
              if (a.expirationDate == null) return 1;
              if (b.expirationDate == null) return -1;
              return a.expirationDate!.compareTo(b.expirationDate!);
            });
            break;
          case SortOption.alphabetical:
            models.sort((a, b) => a.serviceName.compareTo(b.serviceName));
            break;
          case SortOption.mostUpvoted:
            models.sort((a, b) => b.upvotes.compareTo(a.upvotes));
            break;
        }
      }
      
      return models;
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

      if (upvotedBy.contains(userId)) {
        upvotedBy.remove(userId);
        await docRef.update({
          'upvotes': FieldValue.increment(-1),
          'upvotedBy': upvotedBy,
        });
      } else {
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
          await docRef.update({
            'downvotes': FieldValue.increment(-1),
            'downvotedBy': downvotedBy,
          });
        }
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

      if (downvotedBy.contains(userId)) {
        downvotedBy.remove(userId);
        await docRef.update({
          'downvotes': FieldValue.increment(-1),
          'downvotedBy': downvotedBy,
        });
      } else {
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
          await docRef.update({
            'upvotes': FieldValue.increment(-1),
            'upvotedBy': upvotedBy,
          });
        }
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
      // Fetch without orderBy to avoid requiring composite index
      final snapshot = await firestore
          .collection('promoCodes')
          .where('authorId', isEqualTo: userId)
          .get();

      final models = snapshot.docs
          .map((doc) => PromoCodeModel.fromFirestore(doc))
          .toList();
      
      models.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      
      return models;
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
