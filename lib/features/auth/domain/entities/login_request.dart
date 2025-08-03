import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String emailOrUsername;
  final String password;

  const LoginRequest({
    required this.emailOrUsername,
    required this.password,
  });

  @override
  List<Object?> get props => [emailOrUsername, password];
} 