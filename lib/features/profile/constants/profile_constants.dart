/// Constants for profile feature.
class ProfileConstants {
  /// Cloudinary upload presets
  static const String cloudinaryProfileUploadPreset = 'profile_upload';

  /// Error messages
  static const String uploadFailedError = 'Lỗi upload ảnh';
  static const String invalidImageError = 'File không hợp lệ';
  static const String networkError = 'Lỗi mạng';

  /// Form validation messages
  static const String fullNameRequired = 'Vui lòng nhập họ tên';
  static const String usernameRequired = 'Vui lòng nhập tên đăng nhập';
  static const String genderRequired = 'Vui lòng chọn giới tính';
  static const String birthDateRequired = 'Vui lòng chọn ngày sinh';
  static const String currentPasswordRequired =
      'Vui lòng nhập mật khẩu hiện tại';
  static const String newPasswordRequired = 'Vui lòng nhập mật khẩu mới';
  static const String confirmPasswordRequired = 'Vui lòng xác nhận mật khẩu';
  static const String passwordsDoNotMatch = 'Mật khẩu không khớp';
  static const String newPasswordTooWeak = 'Mật khẩu quá yếu';

  /// Success messages
  static const String profileUpdatedSuccess = 'Cập nhật thông tin thành công';

  /// File size limits
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB

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

  /// Supported image formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
  ];

  /// Validation lengths
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

  /// Gender options
  static const List<String> genderOptions = ['male', 'female', 'other'];

  /// Gender display labels
  static const Map<String, String> genderLabels = {
    'male': 'Nam',
    'female': 'Nữ',
    'other': 'Khác',
  };

  /// Default profile settings
  static const String defaultGender = 'male';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
}
