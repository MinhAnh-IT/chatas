import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.username,
    required super.gender,
    required super.birthDate,
    super.profileImageUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    DateTime birthDate;
    try {
      birthDate = DateTime.parse(
        json['birthDate'] ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      birthDate = DateTime.now();
    }

    return UserProfileModel(
      id: json['id'] ?? '', // ID từ Firebase Auth UID
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: birthDate,
      profileImageUrl:
          json['avatarUrl'] ?? null, // Chỉ lấy avatarUrl từ Firebase
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'username': username,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'avatarUrl': profileImageUrl, // Lưu vào avatarUrl để tương thích với auth
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? username,
    String? gender,
    DateTime? birthDate,
    String? profileImageUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
