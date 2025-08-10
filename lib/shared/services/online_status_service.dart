import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/auth/di/online_status_dependency_injection.dart';

class OnlineStatusService {
  static OnlineStatusService? _instance;
  static OnlineStatusService get instance =>
      _instance ??= OnlineStatusService._();

  OnlineStatusService._();

  Timer? _activityTimer;
  Timer? _backgroundTimer;
  bool _isActive = true;
  bool _isInBackground = false;
  final Duration _inactivityThreshold = const Duration(minutes: 5);
  final Duration _backgroundCheckInterval = const Duration(minutes: 1);

  // Stream controllers for real-time updates
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get onlineStatusStream => _onlineStatusController.stream;

  void initialize() {
    _setupActivityDetection();
    _setupBackgroundDetection();
    _startActivityTimer();
  }

  void _setupActivityDetection() {
    // Listen to app lifecycle changes
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        _onAppResumed();
      } else if (msg == AppLifecycleState.paused.toString()) {
        _onAppPaused();
      } else if (msg == AppLifecycleState.detached.toString()) {
        _onAppDetached();
      }
      return null;
    });
  }

  void _setupBackgroundDetection() {
    // For web, we can use visibility API
    if (kIsWeb) {
      // Web-specific background detection
      _setupWebBackgroundDetection();
    }
  }

  void _setupWebBackgroundDetection() {
    // This would need to be implemented with JavaScript interop
    // For now, we'll use a simple timer-based approach
  }

  void _onAppResumed() {
    _isInBackground = false;
    _setActive(true);
    _startActivityTimer();
  }

  void _onAppPaused() {
    _isInBackground = true;
    _setActive(false);
    _startBackgroundTimer();
  }

  void _onAppDetached() {
    _setActive(false);
    _updateOnlineStatus(false);
  }

  void _setActive(bool active) {
    if (_isActive != active) {
      _isActive = active;
      if (active) {
        _updateOnlineStatus(true);
        _startActivityTimer();
      } else {
        _updateOnlineStatus(false);
        _stopActivityTimer();
      }
    }
  }

  void _startActivityTimer() {
    _stopActivityTimer();
    _activityTimer = Timer(_inactivityThreshold, () {
      if (_isActive && !_isInBackground) {
        _setActive(false);
      }
    });
  }

  void _stopActivityTimer() {
    _activityTimer?.cancel();
    _activityTimer = null;
  }

  void _startBackgroundTimer() {
    _stopBackgroundTimer();
    _backgroundTimer = Timer.periodic(_backgroundCheckInterval, (timer) {
      if (_isInBackground) {
        _updateOnlineStatus(false);
      }
    });
  }

  void _stopBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final success = isOnline
            ? await OnlineStatusDependencyInjection.setUserOnlineUseCase(
                currentUser.uid,
              )
            : await OnlineStatusDependencyInjection.setUserOfflineUseCase(
                currentUser.uid,
              );

        if (success) {
          _onlineStatusController.add(isOnline);
        }
      }
    } catch (e) {
      debugPrint('Error updating online status: $e');
    }
  }

  // Manual methods for explicit online status updates
  Future<void> setOnline() async {
    await _updateOnlineStatus(true);
    _setActive(true);
  }

  Future<void> setOffline() async {
    await _updateOnlineStatus(false);
    _setActive(false);
  }

  Future<void> updateLastActive() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await OnlineStatusDependencyInjection.setUserOnlineUseCase(
          currentUser.uid,
        );
      }
    } catch (e) {
      debugPrint('Error updating last active: $e');
    }
  }

  // Method to handle user activity (call this when user interacts with the app)
  void onUserActivity() {
    if (!_isActive && !_isInBackground) {
      _setActive(true);
    }
    _startActivityTimer();
  }

  // Get current online status
  bool get isOnline => _isActive && !_isInBackground;

  // Dispose resources
  void dispose() {
    _stopActivityTimer();
    _stopBackgroundTimer();
    _onlineStatusController.close();
  }
}

// Extension to easily access the service
extension OnlineStatusServiceExtension on BuildContext {
  OnlineStatusService get onlineStatusService => OnlineStatusService.instance;
}
