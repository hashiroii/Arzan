import 'package:equatable/equatable.dart';
import '../../../../features/user/domain/entities/user.dart';

class PromoCode extends Equatable {
  final String id;
  final String code;
  final String serviceName;
  final String authorId;
  final User? author;
  final String? comment;
  final DateTime publishDate;
  final DateTime? expirationDate;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final bool isActive;

  const PromoCode({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.authorId,
    this.author,
    this.comment,
    required this.publishDate,
    this.expirationDate,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.isActive = true,
  });

  int get karma => upvotes - downvotes;
  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());

  PromoCode copyWith({
    String? id,
    String? code,
    String? serviceName,
    String? authorId,
    User? author,
    String? comment,
    DateTime? publishDate,
    DateTime? expirationDate,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    bool? isActive,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      serviceName: serviceName ?? this.serviceName,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      comment: comment ?? this.comment,
      publishDate: publishDate ?? this.publishDate,
      expirationDate: expirationDate ?? this.expirationDate,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    serviceName,
    authorId,
    author,
    comment,
    publishDate,
    expirationDate,
    upvotes,
    downvotes,
    upvotedBy,
    downvotedBy,
    isActive,
  ];
}
