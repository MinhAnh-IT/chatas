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
  /// Supports reply functionality through [replyToMessageId].
  Future<void> call({
    required String chatThreadId,
    required String content,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    MessageType type = MessageType.text,
    String? replyToMessageId,
  }) async {
    final now = DateTime.now();

    final message = ChatMessage(
      id: 'msg_${now.millisecondsSinceEpoch}',
      chatThreadId: chatThreadId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl:
          senderAvatarUrl ?? ChatMessagePageConstants.temporaryAvatarUrl,
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
