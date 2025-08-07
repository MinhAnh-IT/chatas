import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

class CreateChatThreadUseCase {
  final ChatThreadRepository repository;

  CreateChatThreadUseCase(this.repository);

  Future<ChatThread> call({
    required String friendId,
    required String friendName,
    required String friendAvatarUrl,
    String? initialMessage,
  }) async {
    final now = DateTime.now();

    final newChatThread = ChatThread(
      id: 'chat_${friendId}_${now.millisecondsSinceEpoch}',
      name: friendName,
      lastMessage: initialMessage ?? 'Đoạn chat mới được tạo',
      lastMessageTime: now,
      avatarUrl: friendAvatarUrl,
      members: [
        'current_user',
        friendId,
      ], // current_user is the current logged-in user
      isGroup: false,
      unreadCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    await repository.addChatThread(newChatThread);
    return newChatThread;
  }
}
