import 'package:equatable/equatable.dart';

class RegisterRequest extends Equatable {
  final String fullName;
  final String username;
  final String email;
  final String gender;
  final DateTime birthDate;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.password,
  });

  @override
  List<Object?> get props => [
    fullName,
    username,
    email,
    gender,
    birthDate,
    password,
  ];
}
