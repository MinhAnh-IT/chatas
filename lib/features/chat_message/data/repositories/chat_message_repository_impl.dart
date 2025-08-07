import '../datasources/chat_message_remote_data_source.dart';
import '../models/chat_message_model.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_message_repository.dart';

/// Implementation of [ChatMessageRepository] using remote data source.
/// Converts between domain entities and data models while handling errors.
class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageRemoteDataSource _remoteDataSource;

  ChatMessageRepositoryImpl({ChatMessageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ChatMessageRemoteDataSource();

  @override
  Future<List<ChatMessage>> getMessages(String chatThreadId) async {
    try {
      final models = await _remoteDataSource.fetchMessages(chatThreadId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  @override
  Stream<List<ChatMessage>> messagesStream(String chatThreadId) {
    try {
      return _remoteDataSource
          .messagesStream(chatThreadId)
          .map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      throw Exception('Failed to get messages stream: $e');
    }
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      final model = ChatMessageModel.fromEntity(message);
      await _remoteDataSource.addMessage(model);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> updateMessage(ChatMessage message) async {
    try {
      final model = ChatMessageModel.fromEntity(message);
      await _remoteDataSource.updateMessage(message.id, model);
    } catch (e) {
      throw Exception('Failed to update message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await _remoteDataSource.deleteMessage(messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> addReaction(
    String messageId,
    String userId,
    ReactionType reaction,
  ) async {
    try {
      final reactionString = _reactionTypeToString(reaction);
      await _remoteDataSource.addReaction(messageId, userId, reactionString);
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  @override
  Future<void> removeReaction(String messageId, String userId) async {
    try {
      await _remoteDataSource.removeReaction(messageId, userId);
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  @override
  Future<void> markAsRead(String messageId, String userId) async {
    try {
      await _remoteDataSource.updateMessageStatus(messageId, 'read');
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Converts ReactionType enum to string for data layer.
  String _reactionTypeToString(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return 'like';
      case ReactionType.love:
        return 'love';
      case ReactionType.sad:
        return 'sad';
      case ReactionType.angry:
        return 'angry';
      case ReactionType.laugh:
        return 'laugh';
      case ReactionType.wow:
        return 'wow';
    }
  }
}
