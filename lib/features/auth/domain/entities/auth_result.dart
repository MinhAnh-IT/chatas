import 'package:equatable/equatable.dart';
import 'user.dart';
import '../exceptions/auth_exceptions.dart';

abstract class AuthResult extends Equatable {
  const AuthResult();

  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthResult {
  final User? user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthResult {
  final String message;
  final AuthException? exception;

  const AuthFailure(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}
