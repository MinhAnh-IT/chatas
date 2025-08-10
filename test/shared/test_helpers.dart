import 'package:mocktail/mocktail.dart';
import 'package:chatas/shared/services/online_status_service.dart';

/// Mock implementation for OnlineStatusService
class MockOnlineStatusService extends Mock implements OnlineStatusService {
  @override
  void onUserActivity() {}

  @override
  Stream<bool> get onlineStatusStream => Stream.value(true);

  @override
  Future<void> setOnline() async {}

  @override
  Future<void> setOffline() async {}

  @override
  void initialize() {}

  @override
  void dispose() {}
}

/// Test helper to set up OnlineStatusService mocking
class TestOnlineStatusService {
  static MockOnlineStatusService? _mockInstance;

  static MockOnlineStatusService get mockInstance {
    _mockInstance ??= MockOnlineStatusService();
    return _mockInstance!;
  }

  static void setup() {
    _mockInstance = MockOnlineStatusService();
    OnlineStatusService.setTestInstance(_mockInstance);
  }

  static void reset() {
    OnlineStatusService.setTestInstance(null);
    _mockInstance = null;
  }
}
