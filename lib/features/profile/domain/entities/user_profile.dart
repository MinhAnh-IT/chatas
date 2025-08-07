import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String username;
  final String gender;
  final DateTime birthDate;
  final String? profileImageUrl;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.username,
    required this.gender,
    required this.birthDate,
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? username,
    String? gender,
    DateTime? birthDate,
    String? profileImageUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    username,
    gender,
    birthDate,
    profileImageUrl,
  ];
}
