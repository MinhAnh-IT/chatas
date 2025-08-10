import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:chatas/core/constants/app_route_constants.dart';

import '../../domain/entities/chat_thread.dart';
import '../cubit/chat_thread_list_cubit.dart';
import '../cubit/chat_thread_list_state.dart';
import '/shared/widgets/app_bar.dart';
import '/shared/widgets/refreshable_list_view.dart';

class ArchivedThreadsPage extends StatefulWidget {
  const ArchivedThreadsPage({super.key});

  @override
  State<ArchivedThreadsPage> createState() => _ArchivedThreadsPageState();
}

class _ArchivedThreadsPageState extends State<ArchivedThreadsPage> {
  @override
  void initState() {
    super.initState();

    // Get cubit from context (should be provided by parent)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
        if (currentUserId.isNotEmpty) {
          _fetchArchivedThreads(currentUserId);
        }
      }
    });
  }

  void _fetchArchivedThreads(String userId) {
    // Use the dedicated method to get archived threads
    final cubit = context.read<ChatThreadListCubit>();
    cubit.fetchArchivedThreads(userId);
  }

  Future<void> _handleRefresh() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      _fetchArchivedThreads(currentUserId);
    }
  }

  void _navigateToChatMessage(
    BuildContext context,
    String threadId,
    String? otherUserName,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final route = AppRouteConstants.chatMessageRoute(
      threadId,
      currentUserId: currentUserId,
      otherUserName: otherUserName ?? 'Chat',
    );
    context.push(route);
  }

  void _unarchiveThread(ChatThread thread) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      // Unarchive the thread using cubit
      final cubit = context.read<ChatThreadListCubit>();
      cubit.unarchiveThread(thread.id, currentUserId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã khôi phục "${thread.name}" vào danh sách chính'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // No longer need to filter since we're getting archived threads directly
  // List<ChatThread> _filterArchivedThreads(List<ChatThread> allThreads) {
  //   final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  //   if (currentUserId.isEmpty) return [];
  //
  //   // Filter threads that are archived for current user
  //   return allThreads.where((thread) =>
  //     thread.hiddenFor.contains(currentUserId)
  //   ).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Lưu trữ',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ChatThreadListCubit, ChatThreadListState>(
        builder: (context, state) {
          if (state is ChatThreadListLoading) {
            return RefreshableListView<ChatThread>(
              items: const [],
              onRefresh: _handleRefresh,
              isLoading: true,
              itemBuilder: (context, thread, index) => const SizedBox.shrink(),
            );
          }

          if (state is ChatThreadListError) {
            return RefreshableListView<ChatThread>(
              items: const [],
              onRefresh: _handleRefresh,
              errorMessage: state.message,
              onRetry: () {
                final currentUserId =
                    FirebaseAuth.instance.currentUser?.uid ?? '';
                if (currentUserId.isNotEmpty) {
                  _fetchArchivedThreads(currentUserId);
                }
              },
              itemBuilder: (context, thread, index) => const SizedBox.shrink(),
            );
          }

          if (state is ChatThreadListLoaded) {
            // Use threads directly since they're already filtered
            final archivedThreads = state.threads;

            return RefreshableListView<ChatThread>(
              items: archivedThreads,
              onRefresh: _handleRefresh,
              showRefreshMessage: false,
              itemBuilder: (context, thread, index) {
                return ArchivedThreadListTile(
                  thread: thread,
                  onTap: () {
                    _navigateToChatMessage(context, thread.id, thread.name);
                  },
                  onUnarchive: () => _unarchiveThread(thread),
                );
              },
              emptyWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Không có cuộc trò chuyện nào được lưu trữ',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Các cuộc trò chuyện bạn lưu trữ sẽ xuất hiện ở đây',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
    );
  }
}

class ArchivedThreadListTile extends StatelessWidget {
  final ChatThread thread;
  final VoidCallback? onTap;
  final VoidCallback? onUnarchive;

  const ArchivedThreadListTile({
    super.key,
    required this.thread,
    this.onTap,
    this.onUnarchive,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[300],
        backgroundImage: thread.avatarUrl.isNotEmpty
            ? NetworkImage(thread.avatarUrl)
            : null,
        child: thread.avatarUrl.isEmpty
            ? Icon(
                thread.isGroup ? Icons.group : Icons.person,
                color: Colors.grey[600],
              )
            : null,
      ),
      title: Text(
        thread.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (thread.lastMessage.isNotEmpty)
            Text(
              thread.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.archive, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                'Đã lưu trữ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'unarchive':
              onUnarchive?.call();
              break;
            case 'open':
              onTap?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'unarchive',
            child: ListTile(
              leading: Icon(Icons.unarchive),
              title: Text('Khôi phục'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'open',
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text('Mở cuộc trò chuyện'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
