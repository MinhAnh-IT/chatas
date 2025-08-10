import '../datasources/ai/ai_summary_remote_data_source.dart';

/// Repository implementation for AI chat summary.
class AISummaryRepositoryImpl {
  final AISummaryRemoteDataSource remoteDataSource;

  AISummaryRepositoryImpl({required this.remoteDataSource});

  /// Summarizes chat messages using AI.
  /// [messages] is a list of message contents (plain text).
  /// [isManualSummary] determines which prompt to use (default: false for offline summary).
  /// Returns the summary as a string, or throws on error.
  Future<String> summarizeMessages(
    List<String> messages, {
    bool isManualSummary = false,
  }) async {
    try {
      if (messages.isEmpty) {
        throw Exception('No messages provided for summarization');
      }

      return await remoteDataSource.summarizeMessages(
        messages,
        isManualSummary: isManualSummary,
      );
    } catch (e) {
      // Log error for debugging
      rethrow;
    }
  }
}
