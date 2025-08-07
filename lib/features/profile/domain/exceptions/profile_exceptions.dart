abstract class ProfileException implements Exception {
  final String message;
  final String? code;

  const ProfileException(this.message, {this.code});

  @override
  String toString() => 'Lỗi profile: $message';
}

class ProfileUpdateException extends ProfileException {
  const ProfileUpdateException(String message) : super(message);
}

class PasswordChangeException extends ProfileException {
  const PasswordChangeException(String message) : super(message);
}

class ImageUploadException extends ProfileException {
  const ImageUploadException(String message) : super(message);
}

class UserNotFoundException extends ProfileException {
  const UserNotFoundException() : super('Không tìm thấy người dùng');
}

class UsernameAlreadyExistsException extends ProfileException {
  const UsernameAlreadyExistsException() : super('Tên người dùng đã tồn tại');
}

class CurrentPasswordIncorrectException extends ProfileException {
  const CurrentPasswordIncorrectException()
    : super('Mật khẩu hiện tại không đúng');
}
