import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  final String userId;
  final bool isOnline;
  final DateTime lastActive;
  final String fullName;
  final String username;
  final String email;
  final String gender;
  // final String password;
  final DateTime birthDate;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.userId,
    required this.isOnline,
    required this.lastActive,
    required this.fullName,
    required this.username,
    required this.email,
    // required this.password,
    required this.gender,
    required this.birthDate,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'] ?? DateTime.now().toIso8601String(),
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      // password: json['password'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: DateTime.parse(
        json['birthDate'] ?? DateTime.now().toIso8601String(),
      ),
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': fullName,
      'username': username,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      isOnline: user.isOnline,
      lastActive: user.lastActive,
      fullName: user.fullName,
      username: user.username,
      email: user.email,
      gender: user.gender,
      birthDate: user.birthDate,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      userId: userId,
      isOnline: isOnline,
      lastActive: lastActive,
      fullName: fullName,
      username: username,
      email: email,
      gender: gender,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserModel copyWith({
    String? userId,
    bool? isOnline,
    DateTime? lastActive,
    String? fullName,
    String? username,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? password,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => throw UnimplementedError();
}
