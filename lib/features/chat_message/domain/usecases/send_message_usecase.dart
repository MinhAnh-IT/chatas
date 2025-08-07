import '../entities/chat_message.dart';
import '../repositories/chat_message_repository.dart';
import '../../constants/chat_message_page_constants.dart';

/// Use case for sending new chat messages.
/// Handles the business logic for message creation and delivery.
class SendMessageUseCase {
  final ChatMessageRepository repository;

  const SendMessageUseCase(this.repository);

  /// Executes the use case to send a new message.
  /// Creates a [ChatMessage] entity with the provided parameters and sends it.
  Future<void> call({
    required String chatThreadId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    final now = DateTime.now();
    
    // TODO: Get actual user information from auth service
    final message = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch}',
      chatThreadId: chatThreadId,
      senderId: ChatMessagePageConstants.temporaryUserId,
      senderName: ChatMessagePageConstants.temporaryUserName,
      senderAvatarUrl: ChatMessagePageConstants.temporaryAvatarUrl,
      content: content,
      type: type,
      status: MessageStatus.sending,
      sentAt: now,
      replyToMessageId: replyToMessageId,
      createdAt: now,
      updatedAt: now,
    );

    await repository.sendMessage(message);
  }
}
