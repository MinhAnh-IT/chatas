import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:flutter/material.dart';
import 'package:chatas/shared/widgets/app_bar.dart';
import 'package:chatas/shared/widgets/bottom_navigation.dart';
import 'package:chatas/shared/widgets/refreshable_list_view.dart';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:go_router/go_router.dart';
import '../../constants/chat_thread_list_page_constants.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import '../../domain/entities/chat_thread.dart';
import '../cubit/chat_thread_list_cubit.dart';
import '../cubit/chat_thread_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatas/shared/utils/date_utils.dart' as chat_utils;

class ChatThreadListPage extends StatefulWidget {
  const ChatThreadListPage({super.key});

  @override
  State<ChatThreadListPage> createState() => _ChatThreadListPageState();
}

class _ChatThreadListPageState extends State<ChatThreadListPage> {
  late ChatThreadListCubit _cubit;

  @override
  void initState() {
    super.initState();
    final repository = ChatThreadRepositoryImpl();
    final getChatThreadsUseCase = GetChatThreadsUseCase(repository);
    final createChatThreadUseCase = CreateChatThreadUseCase(repository);

    _cubit = ChatThreadListCubit(
      getChatThreadsUseCase: getChatThreadsUseCase,
      createChatThreadUseCase: createChatThreadUseCase,
    );
    _cubit.fetchChatThreads();
  }

  /// Navigates to chat message page when a thread is tapped.
  void _navigateToChatMessage(
    BuildContext context,
    String threadId,
    String threadName,
  ) {
    final route = AppRouteConstants.chatMessageRoute(
      threadId,
      currentUserId: ChatThreadListPageConstants.temporaryUserId,
      otherUserName: threadName,
    );
    context.go(route);
  }

  /// Handles refresh action when user pulls down to refresh.
  Future<void> _handleRefresh() async {
    await _cubit.fetchChatThreads();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ChatThreadListPageConstants.refreshedMessage),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: CommonAppBar(
          title: ChatThreadListPageConstants.title,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: ChatThreadListPageConstants.searchTooltip,
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<ChatThreadListCubit, ChatThreadListState>(
          builder: (context, state) {
            if (state is ChatThreadListLoading) {
              return RefreshableListView<ChatThread>(
                items: const [],
                onRefresh: _handleRefresh,
                isLoading: true,
                itemBuilder: (context, thread, index) =>
                    const SizedBox.shrink(),
              );
            }

            if (state is ChatThreadListError) {
              return RefreshableListView<ChatThread>(
                items: const [],
                onRefresh: _handleRefresh,
                errorMessage: state.message,
                onRetry: () => _cubit.fetchChatThreads(),
                itemBuilder: (context, thread, index) =>
                    const SizedBox.shrink(),
              );
            }

            if (state is ChatThreadListLoaded) {
              final threads = state.threads;
              return RefreshableListView<ChatThread>(
                items: threads,
                onRefresh: _handleRefresh,
                showRefreshMessage: false, // We handle the message manually
                itemBuilder: (context, thread, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(thread.avatarUrl),
                      radius: ChatThreadListPageConstants.avatarRadius,
                    ),
                    title: Text(thread.name),
                    subtitle: Text(thread.lastMessage),
                    trailing: Text(
                      chat_utils.DateUtils.formatTime(thread.lastMessageTime),
                      style: const TextStyle(
                        fontSize: ChatThreadListPageConstants.trailingFontSize,
                      ),
                    ),
                    onTap: () {
                      _navigateToChatMessage(context, thread.id, thread.name);
                    },
                  );
                },
                emptyWidget: const Center(
                  child: Text(ChatThreadListPageConstants.noChats),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: CommonBottomNavigation(
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }
}
