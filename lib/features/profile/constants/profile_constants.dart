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
  static const String currentPasswordRequired =
      'Vui lòng nhập mật khẩu hiện tại';
  static const String newPasswordRequired = 'Vui lòng nhập mật khẩu mới';
  static const String confirmPasswordRequired =
      'Vui lòng xác nhận mật khẩu mới';

  // Gender options (Vietnamese display)
  static const List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];

  // Gender mapping from English to Vietnamese
  static const Map<String, String> genderMapping = {
    'Male': 'Nam',
    'Female': 'Nữ',
    'Other': 'Khác',
    'Nam': 'Nam',
    'Nữ': 'Nữ',
    'Khác': 'Khác',
  };

  // Gender mapping from Vietnamese to English (for database)
  static const Map<String, String> genderToEnglish = {
    'Nam': 'Male',
    'Nữ': 'Female',
    'Khác': 'Other',
  };

  // Minimum lengths
  static const int minUsernameLength = 3;
  static const int minPasswordLength = 8;

  // Helper method to normalize gender value
  static String normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return 'Nam';
    return genderMapping[gender] ?? 'Nam';
  }

  // Helper method to convert to English for database
  static String toEnglishGender(String vietnameseGender) {
    return genderToEnglish[vietnameseGender] ?? 'Male';
  }
}
