import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:chatas/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatas/features/auth/domain/entities/user.dart';

/// Mock implementation for testing.
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('GetCurrentUserUseCase Tests', () {
    late GetCurrentUserUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = GetCurrentUserUseCase(mockRepository);
    });

    group('call', () {
      test('should return user when repository returns user', () async {
        // arrange
        final expectedUser = User(
          userId: 'user_123',
          isOnline: true,
          lastActive: DateTime.now(),
          fullName: 'John Doe',
          username: 'johndoe',
          email: 'john@example.com',
          gender: 'male',
          birthDate: DateTime(1990, 1, 1),
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => expectedUser);

        // act
        final result = await useCase.call();

        // assert
        expect(result, expectedUser);
        verify(() => mockRepository.getCurrentUser()).called(1);
      });

      test('should return null when repository returns null', () async {
        // arrange
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => null);

        // act
        final result = await useCase.call();

        // assert
        expect(result, isNull);
        verify(() => mockRepository.getCurrentUser()).called(1);
      });

      test('should propagate repository exceptions', () async {
        // arrange
        final exception = Exception('Repository error');

        when(() => mockRepository.getCurrentUser()).thenThrow(exception);

        // act & assert
        expect(() => useCase.call(), throwsA(exception));

        verify(() => mockRepository.getCurrentUser()).called(1);
      });

      test('should handle multiple consecutive calls', () async {
        // arrange
        final user1 = User(
          userId: 'user_1',
          isOnline: true,
          lastActive: DateTime.now(),
          fullName: 'User 1',
          username: 'user1',
          email: 'user1@example.com',
          gender: 'male',
          birthDate: DateTime(1990, 1, 1),
          avatarUrl: 'https://example.com/avatar1.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => user1);

        // act
        final result1 = await useCase.call();
        final result2 = await useCase.call();

        // assert
        expect(result1, user1);
        expect(result2, user1);
        verify(() => mockRepository.getCurrentUser()).called(2);
      });

      test('should handle timeout from repository', () async {
        // arrange
        when(() => mockRepository.getCurrentUser()).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          throw Exception('Request timeout');
        });

        // act & assert
        expect(() => useCase.call(), throwsA(isA<Exception>()));

        verify(() => mockRepository.getCurrentUser()).called(1);
      });
    });
  });
}
