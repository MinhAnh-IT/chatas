class AppRouteConstants {
  static const String homePathName = 'home';
  static const String loginPathName = "login";
  static const String chatMessagePathName = 'chat_message';

  static const String homePath = '/';
  static const String loginPath = '/login';
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
