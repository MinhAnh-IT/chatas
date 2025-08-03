import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/shared/utils/auth_validator.dart';
import 'package:chatas/features/auth/constants/auth_constants.dart';
import 'package:chatas/features/auth/domain/entities/register_request.dart';
import 'package:chatas/features/auth/domain/entities/login_request.dart';

void main() {
  group('AuthValidator - Họ và tên', () {
    test('Họ và tên không được để trống', () {
      expect(AuthValidator.validateFullName(''), AuthConstants.fullNameRequired);
      expect(AuthValidator.validateFullName(null), AuthConstants.fullNameRequired);
    });
    test('Họ và tên hợp lệ', () {
      expect(AuthValidator.validateFullName('Nguyễn Văn A'), null);
    });
  });

  group('AuthValidator - Username', () {
    test('Username không được để trống', () {
      expect(AuthValidator.validateUsername(''), AuthConstants.usernameRequired);
      expect(AuthValidator.validateUsername(null), AuthConstants.usernameRequired);
    });
    test('Username quá ngắn', () {
      expect(AuthValidator.validateUsername('ab'), contains('ít nhất'));
    });
    test('Username hợp lệ', () {
      expect(AuthValidator.validateUsername('username123'), null);
    });
  });

  group('AuthValidator - Email', () {
    test('Email không được để trống', () {
      expect(AuthValidator.validateEmail(''), AuthConstants.emailRequired);
      expect(AuthValidator.validateEmail(null), AuthConstants.emailRequired);
    });
    test('Email sai định dạng', () {
      expect(AuthValidator.validateEmail('abc'), AuthConstants.invalidEmail);
      expect(AuthValidator.validateEmail('abc@'), AuthConstants.invalidEmail);
      expect(AuthValidator.validateEmail('abc@a.'), AuthConstants.invalidEmail);
    });
    test('Email hợp lệ', () {
      expect(AuthValidator.validateEmail('abc@gmail.com'), null);
    });
  });

  group('AuthValidator - Mật khẩu', () {
    test('Mật khẩu không được để trống', () {
      expect(AuthValidator.validatePassword(''), AuthConstants.passwordRequired);
      expect(AuthValidator.validatePassword(null), AuthConstants.passwordRequired);
    });
    test('Mật khẩu yếu', () {
      expect(AuthValidator.validatePassword('123'), AuthConstants.weakPassword);
    });
    test('Mật khẩu hợp lệ', () {
      expect(AuthValidator.validatePassword('12345678'), null);
    });
  });

  group('AuthValidator - Xác nhận mật khẩu', () {
    test('Xác nhận mật khẩu không được để trống', () {
      expect(AuthValidator.validateConfirmPassword('', '12345678'), AuthConstants.confirmPasswordRequired);
      expect(AuthValidator.validateConfirmPassword(null, '12345678'), AuthConstants.confirmPasswordRequired);
    });
    test('Mật khẩu không khớp', () {
      expect(AuthValidator.validateConfirmPassword('1234567', '12345678'), AuthConstants.passwordsDoNotMatch);
    });
    test('Mật khẩu khớp', () {
      expect(AuthValidator.validateConfirmPassword('12345678', '12345678'), null);
    });
  });

  group('AuthValidator - Ngày sinh', () {
    test('Ngày sinh không được để trống', () {
      expect(AuthValidator.validateBirthDate(null), AuthConstants.birthDateRequired);
    });
    test('Ngày sinh nhỏ hơn 13 tuổi', () {
      final now = DateTime.now();
      final under13 = DateTime(now.year - 10, now.month, now.day);
      expect(AuthValidator.validateBirthDate(under13), contains('13 tuổi'));
    });
    test('Ngày sinh lớn hơn 120 tuổi', () {
      final now = DateTime.now();
      final over120 = DateTime(now.year - 121, now.month, now.day);
      expect(AuthValidator.validateBirthDate(over120), contains('hợp lệ'));
    });
    test('Ngày sinh hợp lệ', () {
      final now = DateTime.now();
      final valid = DateTime(now.year - 20, now.month, now.day);
      expect(AuthValidator.validateBirthDate(valid), null);
    });
  });

  group('AuthValidator - Giới tính', () {
    test('Giới tính không được để trống', () {
      expect(AuthValidator.validateGender(''), AuthConstants.genderRequired);
      expect(AuthValidator.validateGender(null), AuthConstants.genderRequired);
    });
    test('Giới tính không hợp lệ', () {
      expect(AuthValidator.validateGender('abc'), contains('hợp lệ'));
    });
    test('Giới tính hợp lệ', () {
      for (final gender in AuthConstants.genderOptions) {
        expect(AuthValidator.validateGender(gender), null);
      }
    });
  });

  group('AuthValidator - validateRegisterRequest', () {
    test('Tất cả trường hợp hợp lệ', () {
      final now = DateTime.now();
      final req = RegisterRequest(
        fullName: 'Nguyễn Văn A',
        username: 'username123',
        email: 'abc@gmail.com',
        gender: AuthConstants.genderOptions.first,
        birthDate: DateTime(now.year - 20, now.month, now.day),
        password: '12345678',
        confirmPassword: '12345678',
      );
      expect(AuthValidator.validateRegisterRequest(req), null);
    });
    test('Thiếu trường', () {
      final now = DateTime.now();
      final req = RegisterRequest(
        fullName: '',
        username: '',
        email: '',
        gender: '',
        birthDate: DateTime.now(),
        password: '',
        confirmPassword: '',
      );
      expect(AuthValidator.validateRegisterRequest(req), isNotNull);
    });
  });

  group('AuthValidator - validateLoginRequest', () {
    test('Đăng nhập hợp lệ', () {
      final req = LoginRequest(emailOrUsername: 'abc@gmail.com', password: '12345678');
      expect(AuthValidator.validateLoginRequest(req), null);
    });
    test('Thiếu trường', () {
      final req = LoginRequest(emailOrUsername: '', password: '');
      expect(AuthValidator.validateLoginRequest(req), isNotNull);
    });
  });
}
