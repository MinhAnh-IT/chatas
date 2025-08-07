import 'package:equatable/equatable.dart';

class UpdateProfileRequest extends Equatable {
  final String fullName;
  final String username;
  final String gender;
  final DateTime birthDate;
  final String? profileImageUrl;

  const UpdateProfileRequest({
    required this.fullName,
    required this.username,
    required this.gender,
    required this.birthDate,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
        fullName,
        username,
        gender,
        birthDate,
        profileImageUrl,
      ];
} 