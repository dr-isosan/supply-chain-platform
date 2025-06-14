import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatar;
  final String? phoneNumber;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    this.avatar,
    this.phoneNumber,
    this.bio,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'avatar': avatar,
      'phoneNumber': phoneNumber,
      'bio': bio,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      avatar: map['avatar'],
      phoneNumber: map['phoneNumber'],
      bio: map['bio'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatar,
    String? phoneNumber,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatar: avatar ?? this.avatar,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
