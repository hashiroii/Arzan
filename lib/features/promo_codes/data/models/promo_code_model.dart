import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/promo_code.dart';
import '../../../user/data/models/user_model.dart';

class PromoCodeModel extends PromoCode {
  const PromoCodeModel({
    required super.id,
    required super.code,
    required super.serviceName,
    required super.authorId,
    super.author,
    super.comment,
    required super.publishDate,
    super.expirationDate,
    super.upvotes = 0,
    super.downvotes = 0,
    super.upvotedBy = const [],
    super.downvotedBy = const [],
    super.isActive = true,
  });

  factory PromoCodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final upvotedBy = List<String>.from(data['upvotedBy'] as List? ?? []);
    final downvotedBy = List<String>.from(data['downvotedBy'] as List? ?? []);
    
    final upvotes = (data['upvotes'] as int?) ?? 0;
    final downvotes = (data['downvotes'] as int?) ?? 0;
    
    return PromoCodeModel(
      id: doc.id,
      code: data['code'] as String,
      serviceName: data['serviceName'] as String,
      authorId: data['authorId'] as String,
      comment: data['comment'] as String?,
      publishDate: (data['publishDate'] as Timestamp).toDate(),
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      upvotes: upvotes.clamp(0, double.infinity).toInt(),
      downvotes: downvotes.clamp(0, double.infinity).toInt(),
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  factory PromoCodeModel.fromEntity(PromoCode promoCode) {
    return PromoCodeModel(
      id: promoCode.id,
      code: promoCode.code,
      serviceName: promoCode.serviceName,
      authorId: promoCode.authorId,
      author: promoCode.author,
      comment: promoCode.comment,
      publishDate: promoCode.publishDate,
      expirationDate: promoCode.expirationDate,
      upvotes: promoCode.upvotes,
      downvotes: promoCode.downvotes,
      upvotedBy: promoCode.upvotedBy,
      downvotedBy: promoCode.downvotedBy,
      isActive: promoCode.isActive,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'serviceName': serviceName,
      'authorId': authorId,
      'comment': comment,
      'publishDate': Timestamp.fromDate(publishDate),
      'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'isActive': isActive,
    };
  }

  PromoCode toEntity() {
    return PromoCode(
      id: id,
      code: code,
      serviceName: serviceName,
      authorId: authorId,
      author: author,
      comment: comment,
      publishDate: publishDate,
      expirationDate: expirationDate,
      upvotes: upvotes,
      downvotes: downvotes,
      upvotedBy: upvotedBy,
      downvotedBy: downvotedBy,
      isActive: isActive,
    );
  }
}
