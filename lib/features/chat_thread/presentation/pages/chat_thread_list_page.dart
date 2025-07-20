import 'package:chatas/features/chat_thread/domain/entities/chat_thread.dart';
import 'package:flutter/material.dart';
import 'package:chatas/shared/widgets/app_bar.dart';
import 'package:chatas/shared/widgets/bottom_navigation.dart';
import 'chat_thread_list_page_constants.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';

class ChatThreadListPage extends StatefulWidget {
  const ChatThreadListPage({super.key});

  @override
  State<ChatThreadListPage> createState() => _ChatThreadListPageState();
}

class _ChatThreadListPageState extends State<ChatThreadListPage> {
  late Future<List<ChatThread>> _chatThreadsFuture;

  @override
  void initState() {
    super.initState();
    final repository = ChatThreadRepositoryImpl();
    final usecase = GetChatThreadsUseCase(repository);
    _chatThreadsFuture = usecase.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: ChatThreadListPageConstants.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: ChatThreadListPageConstants.searchTooltip,
            onPressed: () {
              // TODO: Tìm kiếm
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ChatThread>>(
        future: _chatThreadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${ChatThreadListPageConstants.errorPrefix}${snapshot.error}'));
          }
          final threads = snapshot.data ?? [];
          if (threads.isEmpty) {
            return const Center(child: Text(ChatThreadListPageConstants.noChats));
          }
          return ListView.builder(
            itemCount: threads.length,
            itemBuilder: (context, index) {
              final thread = threads[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(thread.avatarUrl),
                  radius: ChatThreadListPageConstants.avatarRadius,
                ),
                title: Text(thread.name),
                subtitle: Text(thread.lastMessage),
                trailing: Text(
                  _formatTime(thread.lastMessageTime),
                  style: const TextStyle(fontSize: ChatThreadListPageConstants.trailingFontSize),
                ),
                onTap: () {
                  // TODO: Mở chi tiết đoạn chat
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
