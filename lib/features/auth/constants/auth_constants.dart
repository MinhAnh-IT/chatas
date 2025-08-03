class AuthConstants {
  static const String usersCollection = 'users';

  static const String emailRequired = 'Vui lòng nhập email';
  static const String passwordRequired = 'Vui lòng nhập mật khẩu';
  static const String confirmPasswordRequired = 'Vui lòng xác nhận mật khẩu';
  static const String passwordsDoNotMatch = 'Mật khẩu xác nhận không khớp';
  static const String fullNameRequired = 'Vui lòng nhập họ và tên';
  static const String usernameRequired = 'Vui lòng nhập tên người dùng';
  static const String genderRequired = 'Vui lòng chọn giới tính';
  static const String birthDateRequired = 'Vui lòng chọn ngày sinh';

  static const String registrationSuccess = 'Đăng ký thành công!';
  static const String loginSuccess = 'Đăng nhập thành công!';
  static const String logoutSuccess = 'Đăng xuất thành công!';

  static const String emailAlreadyInUse = 'Email đã được sử dụng';
  static const String weakPassword = 'Mật khẩu quá yếu';
  static const String invalidEmail = 'Địa chỉ email không hợp lệ';
  static const String userNotFound = 'Không tìm thấy người dùng';
  static const String wrongPassword = 'Sai mật khẩu';
  static const String tooManyRequests = 'Thử quá nhiều lần. Vui lòng thử lại sau';

  static const int minPasswordLength = 8;
  static const int minUsernameLength = 3;

  static const List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];
}
