import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int karma;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.karma = 0,
    required this.createdAt,
    this.lastActiveAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? karma,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      karma: karma ?? this.karma,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
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
      ];
}
