abstract class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => 'Lỗi xác thực: $message';
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('Email đã được sử dụng', code: 'email-already-in-use');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Mật khẩu quá yếu', code: 'weak-password');
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException()
      : super('Địa chỉ email không hợp lệ', code: 'invalid-email');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('Không tìm thấy người dùng', code: 'user-not-found');
}

class WrongPasswordException extends AuthException {
  const WrongPasswordException()
      : super('Sai mật khẩu', code: 'wrong-password');
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super('Thử quá nhiều lần. Vui lòng thử lại sau', code: 'too-many-requests');
}

class NetworkException extends AuthException {
  const NetworkException()
      : super('Lỗi mạng. Vui lòng kiểm tra kết nối Internet của bạn');
}

class UnknownAuthException extends AuthException {
  const UnknownAuthException(String message)
      : super('Lỗi không xác định: $message');
}
