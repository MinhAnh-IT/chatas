import '../../../shared/constants/shared_constants.dart';

/// Constants for friends feature.
class FriendsConstants {
  /// Firebase project configuration
  static const String firebaseProjectId = SharedConstants.firebaseProjectId;

  /// FCM API URLs
  static const String fcmApiBaseUrl = 'https://fcm.googleapis.com/v1/projects';

  /// FCM messages endpoint URL for the current project
  static const String fcmMessagesUrl =
      '$fcmApiBaseUrl/$firebaseProjectId/messages:send';

  /// Error messages
  static const String fcmTokenNotFoundError = 'FCM token not found';
  static const String accessTokenError = 'Could not get access token';
  static const String fcmSendError = 'Failed to send FCM notification';
}
