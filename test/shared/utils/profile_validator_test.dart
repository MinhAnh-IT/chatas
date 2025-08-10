import 'package:flutter_test/flutter_test.dart';

import 'package:chatas/shared/utils/profile_validator.dart';
import 'package:chatas/features/profile/constants/profile_constants.dart';
import 'package:chatas/features/profile/domain/entities/change_password_request.dart';
import 'package:chatas/features/profile/domain/entities/update_profile_request.dart';

void main() {
  group('ProfileValidator', () {
    test('validateFullName returns error when empty', () {
      expect(
        ProfileValidator.validateFullName(''),
        ProfileConstants.fullNameRequired,
      );
    });

    test('validateUsername enforces min length', () {
      expect(
        ProfileValidator.validateUsername('ab')?.contains('ít nhất'),
        true,
      );
    });

    test('validateGender returns error when invalid', () {
      expect(
        ProfileValidator.validateGender('invalid'),
        'Vui lòng chọn giới tính hợp lệ',
      );
    });

    test('validateBirthDate checks age bounds', () {
      final tooYoung = DateTime.now().subtract(const Duration(days: 12 * 365));
      expect(
        ProfileValidator.validateBirthDate(tooYoung),
        'Bạn phải từ 13 tuổi trở lên',
      );
    });

    test('validateUpdateProfileRequest returns null for valid request', () {
      final req = UpdateProfileRequest(
        fullName: 'Valid',
        username: 'validname',
        gender: 'male',
        birthDate: DateTime(2000, 1, 1),
      );
      expect(ProfileValidator.validateUpdateProfileRequest(req), isNull);
    });

    test('validateChangePasswordRequest validates fields', () {
      final req = ChangePasswordRequest(
        currentPassword: '',
        newPassword: 'short',
        confirmNewPassword: 'mismatch',
      );
      // First failing rule is current password required
      expect(
        ProfileValidator.validateChangePasswordRequest(req),
        ProfileConstants.currentPasswordRequired,
      );
    });
  });
}
