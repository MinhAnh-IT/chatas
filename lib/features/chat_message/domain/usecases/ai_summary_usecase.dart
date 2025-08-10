import '../../data/repositories/ai_summary_repository_impl.dart';

/// Use case for summarizing chat messages using AI.
class AISummaryUseCase {
  final AISummaryRepositoryImpl repository;

  AISummaryUseCase({required this.repository});

  /// Summarizes chat messages using AI.
  /// [messages] is a list of message contents (plain text).
  /// [isManualSummary] determines which prompt to use (default: false for offline summary).
  /// Returns the summary as a string, or throws on error.
  Future<String> call(
    List<String> messages, {
    bool isManualSummary = false,
  }) async {
    try {
      if (messages.isEmpty) {
        throw Exception('No messages provided for summarization');
      }

      // Filter out empty messages
      final validMessages = messages
          .where((msg) => msg.trim().isNotEmpty)
          .toList();

      if (validMessages.isEmpty) {
        throw Exception('No valid message content found');
      }

      return await repository.summarizeMessages(
        validMessages,
        isManualSummary: isManualSummary,
      );
    } catch (e) {
      // Log error for debugging
      rethrow;
    }
  }
}
