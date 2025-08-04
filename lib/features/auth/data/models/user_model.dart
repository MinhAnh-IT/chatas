import '../../domain/entities/User.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.username,
    required super.email,
    required super.gender,
    required super.birthDate,
    required super.password,
    required super.confirmPassword,
    required super.avatarUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: DateTime.parse(json['birthDate'] ?? DateTime.now().toIso8601String()),
      password: json['password'] ?? '',
      confirmPassword: json['confirmPassword'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'password': password,
      'confirmPassword': confirmPassword,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      username: user.username,
      email: user.email,
      gender: user.gender,
      birthDate: user.birthDate,
      password: user.password,
      confirmPassword: user.confirmPassword,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      fullName: fullName,
      username: username,
      email: email,
      gender: gender,
      birthDate: birthDate,
      password: password,
      confirmPassword: confirmPassword,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? gender,
    DateTime? birthDate,
    String? password,
    String? confirmPassword,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 