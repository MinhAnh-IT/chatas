import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../features/auth/di/online_status_dependency_injection.dart';

class OnlineStatusService with WidgetsBindingObserver {
  static OnlineStatusService? _instance;
  static OnlineStatusService get instance =>
      _instance ??= OnlineStatusService._();

  OnlineStatusService._();

  Timer? _activityTimer;
  Timer? _backgroundTimer;
  Timer? _terminationTimer;
  bool _isActive = true;
  bool _isInBackground = false;
  // User is considered offline if no interaction for 1 minute
  final Duration _inactivityThreshold = const Duration(minutes: 1);
  final Duration _backgroundCheckInterval = const Duration(minutes: 1);
  final Duration _terminationThreshold = const Duration(seconds: 30);

  // Stream controllers for real-time updates
  final StreamController<bool> _onlineStatusController =
      StreamController<bool>.broadcast();
  Stream<bool> get onlineStatusStream => _onlineStatusController.stream;

  // Callback for when user comes back online after being offline
  VoidCallback? _onUserBackOnlineCallback;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _setupBackgroundDetection();
    _setupAuthStateListener();
    _setupAppTerminationHandler();
    // Mark online as soon as app starts
    setOnline();
    _startActivityTimer();
  }



  void _setupBackgroundDetection() {
    // For web, we can use visibility API
    if (kIsWeb) {
      // Web-specific background detection
      _setupWebBackgroundDetection();
    }
  }

  void _setupAuthStateListener() {
    // Listen to Firebase Auth state changes
    firebase_auth.FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // User logged out or switched account
        _setActive(false);
        _updateOnlineStatus(false);
        _forceOffline();
      } else {
        // User logged in or switched to this account
        _setActive(true);
        _updateOnlineStatus(true);
      }
    });
  }

  void _setupWebBackgroundDetection() {
    // This would need to be implemented with JavaScript interop
    // For now, we'll use a simple timer-based approach
  }

  void _setupAppTerminationHandler() {
    // Handle app termination more aggressively
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        _onAppResumed();
      } else if (msg == AppLifecycleState.paused.toString()) {
        _onAppPaused();
      } else if (msg == AppLifecycleState.detached.toString()) {
        _onAppDetached();
      } else if (msg == AppLifecycleState.hidden.toString()) {
        _onAppHidden();
      }
      
      // Force offline for any non-resumed state
      if (msg != AppLifecycleState.resumed.toString()) {
        _forceOffline();
      }
      
      return null;
    });
  }

  void _onAppResumed() {
    _isInBackground = false;
    _setActive(true);
    _startActivityTimer();
    _stopTerminationTimer();
    
    // Check if user is still logged in and set online
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _updateOnlineStatus(true);
    }
  }

  void _onAppPaused() {
    _isInBackground = true;
    // Immediately mark user offline and update lastActive
    _setActive(false);
    _startBackgroundTimer();
    _startTerminationTimer();
    
    // Set offline when app goes to background
    _updateOnlineStatus(false);
  }

  void _onAppDetached() {
    _setActive(false);
    _updateOnlineStatus(false);
    // Force immediate offline status when app is detached
    _forceOffline();
  }

  void _onAppHidden() {
    // App is hidden (similar to detached but for newer Flutter versions)
    _setActive(false);
    _updateOnlineStatus(false);
    _forceOffline();
  }

  Future<void> _forceOffline() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await OnlineStatusDependencyInjection.setUserOfflineUseCase(
          currentUser.uid,
        );
      }
    } catch (e) {
      debugPrint('Error in forceOffline: $e');
    }
  }

  void _setActive(bool active) {
    if (_isActive != active) {
      final wasOffline = !_isActive;
      _isActive = active;
      if (active) {
        _updateOnlineStatus(true);
        _startActivityTimer();

        // Trigger callback if user was offline and now back online
        if (wasOffline && _onUserBackOnlineCallback != null) {
          _onUserBackOnlineCallback!();
        }
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
        _forceOffline(); // Force offline when inactive
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

  void _startTerminationTimer() {
    _stopTerminationTimer();
    _terminationTimer = Timer(_terminationThreshold, () {
      // If app is still in background after threshold, force offline
      if (_isInBackground) {
        _forceOffline();
      }
    });
  }

  void _stopTerminationTimer() {
    _terminationTimer?.cancel();
    _terminationTimer = null;
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

  // Cleanup any existing online status and set online (for app startup)
  Future<void> cleanupAndSetOnline() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // First set offline to cleanup any existing status
        await OnlineStatusDependencyInjection.setUserOfflineUseCase(
          currentUser.uid,
        );
        
        // Wait a bit to ensure cleanup is processed
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Then set online
        await OnlineStatusDependencyInjection.setUserOnlineUseCase(
          currentUser.uid,
        );
        
        _setActive(true);
        _onlineStatusController.add(true);
      }
    } catch (e) {
      debugPrint('Error in cleanupAndSetOnline: $e');
    }
  }

  // Force cleanup all online statuses for current user (for app restart)
  Future<void> forceCleanup() async {
    try {
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await OnlineStatusDependencyInjection.setUserOfflineUseCase(
          currentUser.uid,
        );
        _setActive(false);
        _onlineStatusController.add(false);
      }
    } catch (e) {
      debugPrint('Error in forceCleanup: $e');
    }
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

  /// Sets a callback to be called when user comes back online after being offline
  void setOnUserBackOnlineCallback(VoidCallback? callback) {
    _onUserBackOnlineCallback = callback;
  }

  // Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopActivityTimer();
    _stopBackgroundTimer();
    _stopTerminationTimer();
    _onlineStatusController.close();
    _onUserBackOnlineCallback = null;
  }

  // WidgetsBindingObserver methods
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.hidden:
        _onAppHidden();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
    }
  }

  void _onAppInactive() {
    // App is inactive (between foreground and background)
    _setActive(false);
    _updateOnlineStatus(false);
    _forceOffline();
  }
}

// Extension to easily access the service
extension OnlineStatusServiceExtension on BuildContext {
  OnlineStatusService get onlineStatusService => OnlineStatusService.instance;
}
