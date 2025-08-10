import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatas/features/auth/di/auth_dependency_injection.dart';

/// Use case for searching chat threads by name or last message content.
class SearchChatThreadsUseCase {
  final ChatThreadRepository repository;

  SearchChatThreadsUseCase(this.repository);

  /// Searches for chat threads containing the given query in name or last message.
  /// For 1-on-1 chats, searches by the friend's actual display name.
  /// For group chats, searches by the group name.
  ///
  /// Returns a filtered list of [ChatThread] objects that match the search query.
  /// The search is case-insensitive and matches both thread names and last messages.
  Future<List<ChatThread>> call(String query, String currentUserId) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final allThreads = await repository.getChatThreads(currentUserId);
    final lowercaseQuery = query.toLowerCase().trim();

    final filteredThreads = <ChatThread>[];

    for (final thread in allThreads) {
      // Get the actual display name for this thread
      final displayName = await _getDisplayName(thread, currentUserId);
      final threadName = displayName.toLowerCase();
      final lastMessage = thread.lastMessage.toLowerCase();

      if (threadName.contains(lowercaseQuery) ||
          lastMessage.contains(lowercaseQuery)) {
        filteredThreads.add(thread);
      }
    }

    return filteredThreads;
  }

  /// Gets the actual display name for a chat thread
  Future<String> _getDisplayName(
    ChatThread thread,
    String currentUserId,
  ) async {
    // For group chats, use the group name
    if (thread.isGroup) {
      return thread.name;
    }

    // For 1-on-1 chats, get the friend's name
    if (thread.members.length == 2) {
      final friendId = thread.members.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );

      if (friendId.isNotEmpty) {
        try {
          // Try to get user info from AuthDependencyInjection first
          final friendUser = await AuthDependencyInjection.authRemoteDataSource
              .getUserById(friendId);

          if (friendUser != null) {
            final friendName = friendUser.fullName.isNotEmpty
                ? friendUser.fullName
                : friendUser.username.isNotEmpty
                ? friendUser.username
                : 'Người dùng';
            return friendName;
          } else {
            // Fallback: Direct Firestore query
            try {
              final firestore = FirebaseFirestore.instance;
              final userDoc = await firestore
                  .collection('users')
                  .doc(friendId)
                  .get();

              if (userDoc.exists) {
                final data = userDoc.data()!;
                final fullName = data['fullName'] as String? ?? '';
                final username = data['username'] as String? ?? '';
                final displayName = fullName.isNotEmpty
                    ? fullName
                    : username.isNotEmpty
                    ? username
                    : 'Người dùng';
                return displayName;
              }
            } catch (e) {
              print(
                'SearchChatThreadsUseCase: Direct Firestore query failed: $e',
              );
            }
          }
        } catch (e) {
          print('SearchChatThreadsUseCase: Error getting friend name: $e');
        }
      }
    }

    // Fallback to original name
    return thread.name;
  }
}
