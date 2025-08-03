import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/auth/domain/exceptions/auth_exceptions.dart';

class AuthExceptionHandler {
  static AuthException handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
        return const WrongPasswordException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      default:
        return UnknownAuthException(e.message ?? 'Authentication failed');
    }
  }

  static AuthException handleFirestoreException(dynamic e) {
    if (e.toString().contains('network')) {
      return const NetworkException();
    }
    return UnknownAuthException('Database error: ${e.toString()}');
  }

  static AuthException handleGenericException(dynamic e) {
    if (e.toString().contains('network') || e.toString().contains('connection')) {
      return const NetworkException();
    }
    return UnknownAuthException(e.toString());
  }
} 