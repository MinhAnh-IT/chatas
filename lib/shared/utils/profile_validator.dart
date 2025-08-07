import '../../features/profile/constants/profile_constants.dart';
import '../../features/profile/domain/entities/update_profile_request.dart';
import '../../features/profile/domain/entities/change_password_request.dart';

class ProfileValidator {
  static String? validateFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return ProfileConstants.fullNameRequired;
    }
    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return ProfileConstants.usernameRequired;
    }

    if (username.length < ProfileConstants.minUsernameLength) {
      return 'Tên người dùng phải có ít nhất ${ProfileConstants.minUsernameLength} ký tự';
    }

    return null;
  }

  static String? validateGender(String? gender) {
    if (gender == null || gender.isEmpty) {
      return ProfileConstants.genderRequired;
    }

    if (!ProfileConstants.genderOptions.contains(gender)) {
      return 'Vui lòng chọn giới tính hợp lệ';
    }

    return null;
  }

  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return ProfileConstants.birthDateRequired;
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (age < 13) {
      return 'Bạn phải từ 13 tuổi trở lên';
    }

    if (age > 120) {
      return 'Vui lòng nhập ngày sinh hợp lệ';
    }

    return null;
  }

  static String? validateCurrentPassword(String? currentPassword) {
    if (currentPassword == null || currentPassword.isEmpty) {
      return ProfileConstants.currentPasswordRequired;
    }
    return null;
  }

  static String? validateNewPassword(String? newPassword) {
    if (newPassword == null || newPassword.isEmpty) {
      return ProfileConstants.newPasswordRequired;
    }

    if (newPassword.length < ProfileConstants.minPasswordLength) {
      return ProfileConstants.newPasswordTooWeak;
    }

    return null;
  }

  static String? validateConfirmPassword(String? confirmPassword, String newPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return ProfileConstants.confirmPasswordRequired;
    }

    if (confirmPassword != newPassword) {
      return ProfileConstants.passwordsDoNotMatch;
    }

    return null;
  }

  static String? validateUpdateProfileRequest(UpdateProfileRequest request) {
    final fullNameError = validateFullName(request.fullName);
    if (fullNameError != null) return fullNameError;

    final usernameError = validateUsername(request.username);
    if (usernameError != null) return usernameError;

    final genderError = validateGender(request.gender);
    if (genderError != null) return genderError;

    final birthDateError = validateBirthDate(request.birthDate);
    if (birthDateError != null) return birthDateError;

    return null;
  }

  static String? validateChangePasswordRequest(ChangePasswordRequest request) {
    final currentPasswordError = validateCurrentPassword(request.currentPassword);
    if (currentPasswordError != null) return currentPasswordError;

    final newPasswordError = validateNewPassword(request.newPassword);
    if (newPasswordError != null) return newPasswordError;

    final confirmPasswordError = validateConfirmPassword(request.confirmNewPassword, request.newPassword);
    if (confirmPasswordError != null) return confirmPasswordError;

    return null;
  }
} 