import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int karma;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final List<String> blockedUsers;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.karma = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.blockedUsers = const [],
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? karma,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    List<String>? blockedUsers,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      karma: karma ?? this.karma,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      blockedUsers: blockedUsers ?? this.blockedUsers,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        karma,
        createdAt,
        lastActiveAt,
        blockedUsers,
      ];
}
