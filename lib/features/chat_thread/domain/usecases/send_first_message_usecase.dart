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
    print('SendFirstMessageUseCase: Starting with thread ID: ${chatThread.id}');
    print(
      'SendFirstMessageUseCase: Thread lastRecreatedAt: ${chatThread.lastRecreatedAt}',
    );
    String actualThreadId = chatThread.id;

    // Check if this is a hidden thread being recreated (has lastRecreatedAt)
    if (chatThread.lastRecreatedAt != null) {
      print(
        'SendFirstMessageUseCase: Reviving hidden thread: ${chatThread.id} for user: ${message.senderId}',
      );
      await chatThreadRepository.reviveThreadForUser(
        chatThread.id,
        message.senderId,
      );
      // Update lastRecreatedAt (now visibilityCutoff) for the user
      await chatThreadRepository.updateVisibilityCutoff(
        chatThread.id,
        message.senderId,
        chatThread.lastRecreatedAt!, // Use the timestamp from the temporary thread
      );
      await chatThreadRepository.resetUnreadCount(
        chatThread.id,
        message.senderId,
      );

      // Use the original thread ID
      actualThreadId = chatThread.id;
      print(
        'SendFirstMessageUseCase: Successfully revived thread: $actualThreadId',
      );
    }
    // Check if this is a temporary thread (starts with 'temp_') - for completely new chats
    else if (chatThread.id.startsWith('temp_')) {
      print('SendFirstMessageUseCase: Processing completely new temporary thread');
      
      // This is a completely new temporary thread
      print(
        'SendFirstMessageUseCase: Creating real thread from temporary thread',
      );
      print(
        'SendFirstMessageUseCase: Temporary thread ID: ${chatThread.id}',
      );
      // Create the actual thread in database
      final now = DateTime.now();
      final realChatThread = ChatThread(
        id: ChatThread.generate1v1ThreadId(chatThread.members[0], chatThread.members[1]),
        name: chatThread.name,
        lastMessage: message.content,
        lastMessageTime: now,
        avatarUrl: chatThread.avatarUrl,
        members: chatThread.members,
        isGroup: chatThread.isGroup,
        unreadCounts: {}, // Start with empty unread counts, will be updated when message is added
        createdAt: now,
        updatedAt: now,
      );

      print(
        'SendFirstMessageUseCase: Real thread ID will be: ${realChatThread.id}',
      );
      print(
        'SendFirstMessageUseCase: Thread members: ${realChatThread.members}',
      );
      // First, add the thread to database
      await chatThreadRepository.createChatThread(realChatThread);
      actualThreadId = realChatThread.id;
      print(
        'SendFirstMessageUseCase: Thread created successfully and added to database',
      );

      // Wait a bit to ensure thread is created before sending message
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      print(
        'SendFirstMessageUseCase: Thread is not temporary, using existing thread ID: $actualThreadId',
      );
    }

    // Send the message with the actual thread ID
    print(
      'SendFirstMessageUseCase: Sending message with thread ID: $actualThreadId',
    );
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
    print(
      'SendFirstMessageUseCase: Message sent successfully, returning thread ID: $actualThreadId',
    );

    return actualThreadId;
  }
}
