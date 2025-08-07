import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
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
import '../widgets/chat_thread_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatThreadListPage extends StatefulWidget {
  const ChatThreadListPage({super.key});

  @override
  State<ChatThreadListPage> createState() => _ChatThreadListPageState();
}

class _ChatThreadListPageState extends State<ChatThreadListPage> {
  late ChatThreadListCubit _cubit;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatThread> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final repository = ChatThreadRepositoryImpl();
    final getChatThreadsUseCase = GetChatThreadsUseCase(repository);
    final createChatThreadUseCase = CreateChatThreadUseCase(repository);
    final searchChatThreadsUseCase = SearchChatThreadsUseCase(repository);
    final deleteChatThreadUseCase = DeleteChatThreadUseCase(repository);

    _cubit = ChatThreadListCubit(
      getChatThreadsUseCase: getChatThreadsUseCase,
      createChatThreadUseCase: createChatThreadUseCase,
      searchChatThreadsUseCase: searchChatThreadsUseCase,
      deleteChatThreadUseCase: deleteChatThreadUseCase,
    );
    _cubit.fetchChatThreads();
  }

  void _onTabTapped(int index) {
    if (index == 3) {
      context.go('/profile');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  /// Shows search dialog and handles search result selection.
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchResults = [];
        _isSearching = false;
      }
    });
  }

  /// Performs search based on the query
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _cubit
        .searchChatThreads(query)
        .then((results) {
          if (mounted) {
            setState(() {
              _searchResults = results;
              _isSearching = false;
            });
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        });
  }

  Widget _buildContent() {
    // If search is visible, show search results or empty message
    if (_isSearchVisible) {
      return _buildSearchResults();
    }

    // Otherwise show normal chat thread list
    return BlocBuilder<ChatThreadListCubit, ChatThreadListState>(
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
            onRetry: () => _cubit.fetchChatThreads(),
            itemBuilder: (context, thread, index) => const SizedBox.shrink(),
          );
        }

        if (state is ChatThreadListLoaded) {
          final threads = state.threads;
          return RefreshableListView<ChatThread>(
            items: threads,
            onRefresh: _handleRefresh,
            showRefreshMessage: false, // We handle the message manually
            itemBuilder: (context, thread, index) {
              return ChatThreadListTile(
                thread: thread,
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
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.trim().isEmpty) {
      return const Center(
        child: Text(
          ChatThreadListPageConstants.searchEmptyHint,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          ChatThreadListPageConstants.noSearchResults,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return RefreshableListView<ChatThread>(
      items: _searchResults,
      onRefresh: _handleRefresh,
      showRefreshMessage: false,
      itemBuilder: (context, thread, index) {
        return ChatThreadListTile(
          thread: thread,
          onTap: () {
            _navigateToChatMessage(context, thread.id, thread.name);
          },
        );
      },
      emptyWidget: const Center(
        child: Text(ChatThreadListPageConstants.noSearchResults),
      ),
    );
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
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            if (_isSearchVisible)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: ChatThreadListPageConstants.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Đóng tìm kiếm',
                      onPressed: () {
                        _toggleSearch(); // Ẩn search bar thay vì chỉ clear text
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onChanged: _performSearch,
                  autofocus: true,
                ),
              ),
            // Content
            Expanded(child: _buildContent()),
          ],
        ),
        bottomNavigationBar: CommonBottomNavigation(
          currentIndex: 0,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
