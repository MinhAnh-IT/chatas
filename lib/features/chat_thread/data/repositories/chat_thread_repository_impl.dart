import 'package:chatas/features/chat_thread/domain/repositories/chat_thread_repository.dart';
import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';

class ChatThreadRepositoryImpl implements ChatThreadRepository {
  @override
  Future<List<ChatThread>> getChatThreads() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ChatThread(
        id: '1',
        name: 'Nguyễn Văn A',
        lastMessage: 'Chào bạn!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 2)),
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
      ),
      ChatThread(
        id: '2',
        name: 'Trần Thị B',
        lastMessage: 'Hẹn gặp lại nhé!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
      ),
      ChatThread(
        id: '3',
        name: 'Lê Văn C',
        lastMessage: 'Đã nhận được file.',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      ChatThread(
        id: '4',
        name: 'Phạm Thị D',
        lastMessage: 'Cảm ơn bạn nhiều!',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
      ),
      ChatThread(
        id: '5',
        name: 'Hoàng Văn E',
        lastMessage: 'Đang online.',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
    ];
  }
}
