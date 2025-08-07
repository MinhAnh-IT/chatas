import '../../features/auth/constants/auth_constants.dart';
import '../../features/auth/domain/entities/register_request.dart';
import '../../features/auth/domain/entities/login_request.dart';

class AuthValidator {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return AuthConstants.emailRequired;
    }

    final emailRegex = RegExp(r'^[\w\.-]+@gmail\.com$');
    if (!emailRegex.hasMatch(email)) {
      return AuthConstants.invalidEmail;
    }
    
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AuthConstants.passwordRequired;
    }
    
    if (password.length < AuthConstants.minPasswordLength) {
      return AuthConstants.weakPassword;
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? confirmPassword, String password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AuthConstants.confirmPasswordRequired;
    }
    
    if (confirmPassword != password) {
      return AuthConstants.passwordsDoNotMatch;
    }
    
    return null;
  }

  static String? validateFullName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return AuthConstants.fullNameRequired;
    }
    
    return null;
  }

  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return AuthConstants.usernameRequired;
    }

    if (username.length < AuthConstants.minUsernameLength) {
      return 'Tên người dùng phải có ít nhất ${AuthConstants.minUsernameLength} ký tự';
    }

    return null;
  }

  static String? validateGender(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AuthConstants.genderRequired;
    }

    if (!AuthConstants.genderOptions.contains(gender)) {
      return 'Vui lòng chọn giới tính hợp lệ';
    }

    return null;
  }


  static String? validateBirthDate(DateTime? birthDate) {
    if (birthDate == null) {
      return AuthConstants.birthDateRequired;
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


  static String? validateRegisterRequest(RegisterRequest request) {
    final emailError = validateEmail(request.email);
    if (emailError != null) return emailError;
    
    final passwordError = validatePassword(request.password);
    if (passwordError != null) return passwordError;
    
    // final confirmPasswordError = validateConfirmPassword(request.confirmPassword, request.password);
    // if (confirmPasswordError != null) return confirmPasswordError;
    
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

  static String? validateLoginRequest(LoginRequest request) {

    final emailOrUsernameError = validateEmailOrUsername(request.emailOrUsername);
    if (emailOrUsernameError != null) return emailOrUsernameError;
    

    final passwordError = validatePassword(request.password);
    if (passwordError != null) return passwordError;
    
    return null;
  }

  static String? validateEmailOrUsername(String? emailOrUsername) {
    if (emailOrUsername == null || emailOrUsername.trim().isEmpty) {
      return 'Email hoặc tên đăng nhập là bắt buộc';
    }
    
    // If it's an email, validate email format
    if (emailOrUsername.contains('@')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(emailOrUsername)) {
        return 'Email không hợp lệ';
      }
    } else {
      // If it's a username, validate username format
      if (emailOrUsername.length < AuthConstants.minUsernameLength) {
        return 'Tên đăng nhập phải có ít nhất ${AuthConstants.minUsernameLength} ký tự';
      }
    }
    
    return null;
  }
} 