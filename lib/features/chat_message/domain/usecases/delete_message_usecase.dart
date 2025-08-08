import '../repositories/chat_message_repository.dart';

/// UseCase for deleting a chat message.
/// Handles the business logic for message deletion with ownership validation.
class DeleteMessageUseCase {
  final ChatMessageRepository _repository;

  const DeleteMessageUseCase({required ChatMessageRepository repository})
    : _repository = repository;

  /// Deletes an existing message (soft delete).
  ///
  /// [messageId] The ID of the message to delete
  /// [userId] The ID of the user attempting to delete (for ownership validation)
  /// 
  /// Throws [Exception] if user doesn't own the message or deletion fails
  Future<void> call({
    required String messageId,
    required String userId,
  }) async {
    await _repository.deleteMessageWithValidation(
      messageId: messageId,
      userId: userId,
    );
  }
}
