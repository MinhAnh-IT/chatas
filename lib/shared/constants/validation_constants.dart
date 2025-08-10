/// Constants for validation rules and patterns.
class ValidationConstants {
  /// Email validation
  static const String emailPattern = r'^[\w\.-]+@gmail\.com$';
  static const String generalEmailPattern = r'^[\w\.-]+@[\w\.-]+\.\w+$';

  /// Password validation
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;

  /// Username validation
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  /// Phone number validation
  static const String phonePattern = r'^\+?[1-9]\d{1,14}$';

  /// Name validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const String namePattern = r'^[a-zA-ZÀ-ỹ\s]{2,50}$';

  /// Common validation lengths
  static const int maxTextFieldLength = 255;
  static const int maxDescriptionLength = 1000;
}
