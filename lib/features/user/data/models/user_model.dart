import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.karma = 0,
    required super.createdAt,
    super.lastActiveAt,
    super.blockedUsers = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      karma: (data['karma'] as int?) ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: data['lastActiveAt'] != null
          ? (data['lastActiveAt'] as Timestamp).toDate()
          : null,
      blockedUsers: List<String>.from(data['blockedUsers'] as List? ?? []),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      karma: user.karma,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
      blockedUsers: user.blockedUsers,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'karma': karma,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
      'blockedUsers': blockedUsers,
    };
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      karma: karma,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      blockedUsers: blockedUsers,
    );
  }
}
