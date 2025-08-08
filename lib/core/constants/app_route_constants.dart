class AppRouteConstants {
  static const String homePathName = 'home';
  static const String loginPathName = "login";
  static const String registerPathName = "register";
  static const String forgotPasswordPathName = "forgot-password";
  static const String profilePathName = "profile";
  static const String friendsPathName = "friends";
  static const String friendSearchPathName = "friend-search";
  static const String friendRequestsPathName = "friend-requests";
  static const String notificationsPathName = "notifications";

  static const String chatMessagePathName = 'chat_message';

  static const String homePath = '/';
  static const String loginPath = '/login';
  static const String friendsPath = '/friends';
  static const String friendSearchPath = '/friend-search';
  static const String friendRequestsPath = '/friends/requests';
  static const String notificationsPath = '/notifications';
  static const String chatMessagePath = '/chat-message';

  /// Generates a chat message route with parameters
  static String chatMessageRoute(
    String threadId, {
    String? currentUserId,
    String? otherUserName,
  }) {
    final uri = Uri(
      path: '$chatMessagePath/$threadId',
      queryParameters: {
        if (currentUserId != null) 'currentUserId': currentUserId,
        if (otherUserName != null) 'otherUserName': otherUserName,
      },
    );
    return uri.toString();
  }
}
