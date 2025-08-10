import 'package:chatas/features/auth/domain/entities/user.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/domain/usecases/ai_summary_usecase.dart';

/// Service for managing offline chat summary functionality.
/// This service handles the logic for determining when a user was offline
/// and summarizing messages sent during that period.
class OfflineSummaryService {
  final AISummaryUseCase _aiSummaryUseCase;

  OfflineSummaryService({required AISummaryUseCase aiSummaryUseCase})
    : _aiSummaryUseCase = aiSummaryUseCase;

  /// Determines if a user was offline based on their last active time.
  /// [user] is the user entity containing lastActive timestamp.
  /// [currentTime] is the current time (defaults to DateTime.now()).
  /// Returns true if user was offline for more than 5 minutes.
  bool wasUserOffline(User user, [DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    final timeDifference = now.difference(user.lastActive);

    // Consider user offline if inactive for more than 5 minutes
    return timeDifference.inMinutes > 5;
  }

  /// Gets the duration the user was offline.
  /// [user] is the user entity containing lastActive timestamp.
  /// [currentTime] is the current time (defaults to DateTime.now()).
  /// Returns the Duration the user was offline.
  Duration getOfflineDuration(User user, [DateTime? currentTime]) {
    final now = currentTime ?? DateTime.now();
    return now.difference(user.lastActive);
  }

  /// Filters messages sent while the user was offline.
  /// [allMessages] is the list of all messages in the chat.
  /// [lastActive] is the timestamp when the user was last active.
  /// Returns a list of messages sent after the user's last active time.
  List<ChatMessage> getOfflineMessages(
    List<ChatMessage> allMessages,
    DateTime lastActive,
  ) {
    return allMessages
        .where((message) => message.createdAt.isAfter(lastActive))
        .toList();
  }

  /// Gets text content from messages for AI summarization.
  /// [messages] is the list of messages to extract content from.
  /// Returns a list of formatted message strings with sender names and timestamps.
  List<String> extractMessageContent(List<ChatMessage> messages) {
    // Filter text messages and sort by sentAt (oldest first)
    final textMessages = messages
        .where(
          (message) =>
              message.content.isNotEmpty && message.type == MessageType.text,
        )
        .toList();

    // Sort by sentAt in ascending order (oldest first)
    textMessages.sort((a, b) => a.sentAt.compareTo(b.sentAt));

    // Format each message with sender name and content
    return textMessages
        .map((message) => '${message.senderName}: ${message.content}')
        .toList();
  }

  /// Summarizes offline messages using AI.
  /// [messages] is the list of messages to summarize.
  /// Returns the AI-generated summary as a string.
  Future<String> summarizeOfflineMessages(List<ChatMessage> messages) async {
    final content = extractMessageContent(messages);

    if (content.isEmpty) {
      throw Exception('No text content found in messages for summarization');
    }

    return await _aiSummaryUseCase(content);
  }

  /// Checks if there are any new messages to summarize.
  /// [messages] is the list of messages to check.
  /// [lastActive] is the timestamp when the user was last active.
  /// Returns true if there are new messages to summarize.
  bool hasNewMessagesToSummarize(
    List<ChatMessage> messages,
    DateTime lastActive,
  ) {
    final offlineMessages = getOfflineMessages(messages, lastActive);
    final content = extractMessageContent(offlineMessages);
    return content.isNotEmpty;
  }
}
