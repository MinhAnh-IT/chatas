import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatas/features/auth/domain/usecases/get_current_user_with_status_usecase.dart';
import 'package:chatas/features/auth/domain/entities/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('GetCurrentUserWithStatusUseCase', () {
    late GetCurrentUserWithStatusUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = GetCurrentUserWithStatusUseCase(repository: mockRepository);
    });

    test('should return current user when repository call succeeds', () async {
      // Arrange
      final now = DateTime.now();
      final user = User(
        userId: 'user123',
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        gender: 'male',
        birthDate: now.subtract(const Duration(days: 365 * 25)),
        avatarUrl: 'https://example.com/avatar.jpg',
        isOnline: true,
        lastActive: now,
        createdAt: now,
        updatedAt: now,
      );

      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => user);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(user));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when repository call fails', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenThrow(Exception('Repository error'));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return null when repository returns null', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });
  });
}
