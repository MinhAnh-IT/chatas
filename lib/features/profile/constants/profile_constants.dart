class ProfileConstants {
  // Success messages
  static const String profileUpdatedSuccess = 'Cập nhật thông tin thành công!';
  static const String passwordChangedSuccess = 'Đổi mật khẩu thành công!';
  static const String imageUploadedSuccess = 'Tải ảnh lên thành công!';

  // Error messages
  static const String profileUpdateFailed = 'Cập nhật thông tin thất bại';
  static const String passwordChangeFailed = 'Đổi mật khẩu thất bại';
  static const String imageUploadFailed = 'Tải ảnh lên thất bại';
  static const String currentPasswordIncorrect = 'Mật khẩu hiện tại không đúng';
  static const String newPasswordTooWeak = 'Mật khẩu mới quá yếu';
  static const String passwordsDoNotMatch = 'Mật khẩu xác nhận không khớp';
  static const String usernameAlreadyExists = 'Tên người dùng đã tồn tại';

  // Validation messages
  static const String fullNameRequired = 'Vui lòng nhập họ và tên';
  static const String usernameRequired = 'Vui lòng nhập tên người dùng';
  static const String genderRequired = 'Vui lòng chọn giới tính';
  static const String birthDateRequired = 'Vui lòng chọn ngày sinh';
  static const String currentPasswordRequired = 'Vui lòng nhập mật khẩu hiện tại';
  static const String newPasswordRequired = 'Vui lòng nhập mật khẩu mới';
  static const String confirmPasswordRequired = 'Vui lòng xác nhận mật khẩu mới';

  // Gender options
  static const List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];

  // Minimum lengths
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 8;
} 