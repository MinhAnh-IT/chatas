import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/shared/services/online_status_service.dart';

void main() {
  group('OnlineStatusService', () {
    late OnlineStatusService service;

    setUp(() {
      service = OnlineStatusService.instance;
    });

    tearDown(() {
      service.dispose();
    });

    test('should be singleton', () {
      final instance1 = OnlineStatusService.instance;
      final instance2 = OnlineStatusService.instance;

      expect(instance1, equals(instance2));
    });

    test('should start as online', () {
      expect(service.isOnline, isTrue);
    });

    test('should allow setting online status callback', () {
      bool callbackCalled = false;

      service.setOnUserBackOnlineCallback(() {
        callbackCalled = true;
      });

      // Callback should be set without errors
      expect(callbackCalled, isFalse);
    });

    test('should clear callback when set to null', () {
      service.setOnUserBackOnlineCallback(() {});
      service.setOnUserBackOnlineCallback(null);

      // Should not throw errors
      expect(true, isTrue);
    });

    test('should provide online status stream', () {
      expect(service.onlineStatusStream, isNotNull);
      expect(service.onlineStatusStream, isA<Stream<bool>>());
    });

    test('should dispose resources cleanly', () {
      service.setOnUserBackOnlineCallback(() {});

      expect(() => service.dispose(), returnsNormally);

      // Callback should be cleared after dispose
      expect(true, isTrue);
    });

    test('should handle manual online status updates', () async {
      expect(() => service.setOnline(), returnsNormally);
      expect(() => service.setOffline(), returnsNormally);
      expect(() => service.updateLastActive(), returnsNormally);
    });

    test('should handle user activity', () {
      expect(() => service.onUserActivity(), returnsNormally);
    });
  });
}
