import '../repositories/chat_message_repository.dart';

/// UseCase for editing a chat message.
/// Handles the business logic for message editing with ownership validation.
class EditMessageUseCase {
  final ChatMessageRepository _repository;

  const EditMessageUseCase({required ChatMessageRepository repository})
    : _repository = repository;

  /// Edits the content of an existing message.
  ///
  /// [messageId] The ID of the message to edit
  /// [newContent] The new content for the message
  /// [userId] The ID of the user attempting to edit (for ownership validation)
  /// 
  /// Throws [Exception] if user doesn't own the message or edit fails
  Future<void> call({
    required String messageId,
    required String newContent,
    required String userId,
  }) async {
    if (newContent.trim().isEmpty) {
      throw Exception('Message content cannot be empty');
    }

    await _repository.editMessage(
      messageId: messageId,
      newContent: newContent.trim(),
      userId: userId,
    );
  }
}
