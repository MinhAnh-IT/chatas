import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../constants/chat_message_remote_constants.dart';

/// Remote data source for summarizing chat messages using Google Gemini API.
class AISummaryRemoteDataSource {
  final String apiKey;
  final String model;

  AISummaryRemoteDataSource({
    required this.apiKey,
    this.model = ChatMessageRemoteConstants.geminiModel,
  }) : assert(apiKey.isNotEmpty);

  /// Summarizes a list of chat messages using Google Gemini API.
  /// [messages] is a list of message contents (plain text).
  /// [isManualSummary] determines which prompt to use (default: false for offline summary).
  /// Returns the summary as a string, or throws on error.
  Future<String> summarizeMessages(
    List<String> messages, {
    bool isManualSummary = false,
  }) async {
    print('messages: $messages');
    if (messages.isEmpty) {
      throw Exception('No messages provided for summarization');
    }

    final url = Uri.parse(
      '${ChatMessageRemoteConstants.geminiApiBaseUrl}/$model:${ChatMessageRemoteConstants.geminiApiEndpoint}?key=$apiKey',
    );

    final prompt = messages.join('\n');
    final selectedPrompt = isManualSummary
        ? ChatMessageRemoteConstants.manualSummaryPrompt
        : ChatMessageRemoteConstants.offlineSummaryPrompt;

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$selectedPrompt$prompt'},
          ],
        },
      ],
    });

    try {
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 30));

      print('response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final summary =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'];

        if (summary is String && summary.isNotEmpty) {
          return summary;
        } else {
          throw Exception('No summary returned from AI API');
        }
      } else {
        throw Exception(
          'Failed to summarize: ${response.statusCode} ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
