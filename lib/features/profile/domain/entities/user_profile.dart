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