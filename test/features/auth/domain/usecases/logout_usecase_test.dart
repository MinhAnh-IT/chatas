import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:chatas/features/auth/domain/usecases/logout_usecase.dart';
import 'package:chatas/features/auth/domain/repositories/auth_repository.dart';
import 'package:chatas/features/auth/domain/entities/auth_result.dart';

/// Mock implementation for testing.
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('LogoutUseCase Tests', () {
    late LogoutUseCase useCase;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = LogoutUseCase(mockRepository);
    });

    group('call', () {
      test('should call repository logout and complete successfully', () async {
        // arrange
        const authSuccess = AuthSuccess(null);
        when(
          () => mockRepository.logout(),
        ).thenAnswer((_) async => authSuccess);

        // act
        final result = await useCase.call();

        // assert
        expect(result, authSuccess);
        verify(() => mockRepository.logout()).called(1);
      });

      test('should propagate repository exceptions', () async {
        // arrange
        final exception = Exception('Logout failed');

        when(() => mockRepository.logout()).thenThrow(exception);

        // act & assert
        expect(() => useCase.call(), throwsA(exception));

        verify(() => mockRepository.logout()).called(1);
      });

      test('should handle multiple logout calls', () async {
        // arrange
        const authSuccess = AuthSuccess(null);
        when(
          () => mockRepository.logout(),
        ).thenAnswer((_) async => authSuccess);

        // act
        await useCase.call();
        await useCase.call();
        await useCase.call();

        // assert
        verify(() => mockRepository.logout()).called(3);
      });

      test('should handle network timeout during logout', () async {
        // arrange
        when(() => mockRepository.logout()).thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          throw Exception('Network timeout');
        });

        // act & assert
        expect(() => useCase.call(), throwsA(isA<Exception>()));

        verify(() => mockRepository.logout()).called(1);
      });

      test('should complete even if repository takes time', () async {
        // arrange
        const authSuccess = AuthSuccess(null);
        when(() => mockRepository.logout()).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return authSuccess;
        });

        // act
        final stopwatch = Stopwatch()..start();
        final result = await useCase.call();
        stopwatch.stop();

        // assert
        expect(result, authSuccess);
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
        verify(() => mockRepository.logout()).called(1);
      });
    });
  });
}
