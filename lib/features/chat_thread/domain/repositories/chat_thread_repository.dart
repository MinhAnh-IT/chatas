import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

abstract class ChatThreadRepository {
  Future<List<ChatThread>> getChatThreads();
  Future<void> addChatThread(ChatThread chatThread);
}
