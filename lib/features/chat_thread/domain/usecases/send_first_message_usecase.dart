import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';
import '../../../chat_message/domain/entities/chat_message.dart';
import '../../../chat_message/domain/repositories/chat_message_repository.dart';

/// Use case for sending the first message and creating chat thread if needed
class SendFirstMessageUseCase {
  final ChatThreadRepository chatThreadRepository;
  final ChatMessageRepository chatMessageRepository;

  SendFirstMessageUseCase({
    required this.chatThreadRepository,
    required this.chatMessageRepository,
  });

  /// Sends the first message and creates chat thread in database if it's temporary
  /// 
  /// [chatThread] The chat thread (might be temporary)
  /// [message] The message to send
  /// 
  /// Returns the actual thread ID after creation
  Future<String> call({
    required ChatThread chatThread,
    required ChatMessage message,
  }) async {
    String actualThreadId = chatThread.id;

    // Check if this is a temporary thread (starts with 'temp_')
    if (chatThread.id.startsWith('temp_')) {
      // Create the actual thread in database
      final now = DateTime.now();
      final realChatThread = ChatThread(
        id: 'chat_${chatThread.members[1]}_${now.millisecondsSinceEpoch}',
        name: chatThread.name,
        lastMessage: message.content,
        lastMessageTime: now,
        avatarUrl: chatThread.avatarUrl,
        members: chatThread.members,
        isGroup: chatThread.isGroup,
        unreadCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      // First, add the thread to database
      await chatThreadRepository.addChatThread(realChatThread);
      actualThreadId = realChatThread.id;
      
      // Wait a bit to ensure thread is created before sending message
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Send the message with the actual thread ID
    final messageWithRealId = ChatMessage(
      id: message.id,
      chatThreadId: actualThreadId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatarUrl: message.senderAvatarUrl,
      content: message.content,
      type: message.type,
      status: message.status,
      sentAt: message.sentAt,
      createdAt: message.createdAt,
      updatedAt: message.updatedAt,
      reactions: message.reactions,
      isDeleted: message.isDeleted,
      editedAt: message.editedAt,
      replyToMessageId: message.replyToMessageId,
    );

    await chatMessageRepository.sendMessage(messageWithRealId);
    
    return actualThreadId;
  }
}
