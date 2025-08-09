import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatas/shared/widgets/app_bar.dart';
import 'package:chatas/shared/widgets/bottom_navigation.dart';
import 'package:chatas/shared/widgets/refreshable_list_view.dart';
import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../constants/chat_thread_list_page_constants.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import '../../domain/entities/chat_thread.dart';
import '../cubit/chat_thread_list_cubit.dart';
import '../cubit/chat_thread_list_state.dart';
import '../widgets/chat_thread_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatas/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:chatas/features/notifications/presentation/cubit/notification_state.dart';
import 'package:chatas/features/notifications/notification_injection.dart'
    as notification_di;
import 'friend_selection_page.dart';

class ChatThreadListPage extends StatefulWidget {
  const ChatThreadListPage({super.key});

  @override
  State<ChatThreadListPage> createState() => _ChatThreadListPageState();
}

class _ChatThreadListPageState extends State<ChatThreadListPage>
    with WidgetsBindingObserver {
  late ChatThreadListCubit _cubit;
  late NotificationCubit _notificationCubit;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatThread> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final repository = ChatThreadRepositoryImpl();
    final getChatThreadsUseCase = GetChatThreadsUseCase(repository);
    final createChatThreadUseCase = CreateChatThreadUseCase(repository);
    final searchChatThreadsUseCase = SearchChatThreadsUseCase(repository);
    final deleteChatThreadUseCase = DeleteChatThreadUseCase(repository);
    final findOrCreateChatThreadUseCase = FindOrCreateChatThreadUseCase(
      repository,
    );

    _cubit = ChatThreadListCubit(
      getChatThreadsUseCase: getChatThreadsUseCase,
      createChatThreadUseCase: createChatThreadUseCase,
      searchChatThreadsUseCase: searchChatThreadsUseCase,
      deleteChatThreadUseCase: deleteChatThreadUseCase,
      findOrCreateChatThreadUseCase: findOrCreateChatThreadUseCase,
    );

    // Khởi tạo notification cubit
    _notificationCubit = NotificationCubit(
      initializeNotifications: notification_di.sl(),
      getNotifications: notification_di.sl(),
      markAsRead: notification_di.sl(),
      getUnreadCount: notification_di.sl(),
      sendFriendRequestNotification: notification_di.sl(),
      sendFriendAcceptedNotification: notification_di.sl(),
    );

    // Get current user ID and fetch threads
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    print('ChatThreadListPage: initState - Current user ID: $currentUserId');
    print(
      'ChatThreadListPage: initState - FirebaseAuth current user: ${FirebaseAuth.instance.currentUser?.email}',
    );
    if (currentUserId.isNotEmpty) {
      _cubit.fetchChatThreads(currentUserId);
    } else {
      print('ChatThreadListPage: initState - No current user found!');
    }

    _notificationCubit.getUnreadCount();

    // Refresh notification count mỗi 30 giây
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _notificationCubit.getUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh chat threads when app comes back to foreground
      print('ChatThreadListPage: App resumed, refreshing chat threads');
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isNotEmpty) {
        _cubit.fetchChatThreads(currentUserId);
      }
    }
  }

  /// Navigates to chat message page when a thread is tapped.
  void _navigateToChatMessage(
    BuildContext context,
    String threadId,
    String threadName,
  ) {
    // Get current user ID from Firebase Auth
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    print('ChatThreadListPage: Navigating with currentUserId: $currentUserId');

    final route = AppRouteConstants.chatMessageRoute(
      threadId,
      currentUserId: currentUserId,
      otherUserName: threadName,
    );
    context.go(route);
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo nhóm chat'),
        content: const Text('Chọn loại chat bạn muốn tạo:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to friend selection for 1-on-1 chat
              _navigateToFriendSelection(false);
            },
            child: const Text('Chat 1-1'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to friend selection for group chat
              _navigateToFriendSelection(true);
            },
            child: const Text('Nhóm chat'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _navigateToFriendSelection(bool isGroupChat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendSelectionPage(
          isGroupChat: isGroupChat,
          onCreateChat: () {
            // Refresh the chat thread list after creating a new chat
            _handleRefresh();
          },
        ),
      ),
    );
  }

  /// Handles refresh action when user pulls down to refresh.
  Future<void> _handleRefresh() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      await _cubit.fetchChatThreads(currentUserId);
    }

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

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    _cubit
        .searchChatThreads(query, currentUserId)
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
            onRetry: () {
              final currentUserId =
                  FirebaseAuth.instance.currentUser?.uid ?? '';
              if (currentUserId.isNotEmpty) {
                _cubit.fetchChatThreads(currentUserId);
              }
            },
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
    // Always refresh when this page is built (e.g., when returning from another page)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('ChatThreadListPage: Building page, refreshing chat threads');
        final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
        print('ChatThreadListPage: build - Current user ID: $currentUserId');
        print(
          'ChatThreadListPage: build - FirebaseAuth current user: ${FirebaseAuth.instance.currentUser?.email}',
        );
        if (currentUserId.isNotEmpty) {
          _cubit.fetchChatThreads(currentUserId);
        } else {
          print('ChatThreadListPage: build - No current user found!');
        }
      }
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _notificationCubit),
      ],
      child: Scaffold(
        appBar: CommonAppBar(
          title: ChatThreadListPageConstants.title,
          actions: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      tooltip: 'Thông báo',
                      onPressed: () {
                        context.go(AppRouteConstants.notificationsPath);
                      },
                    ),
                    if (state is NotificationLoaded && state.unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${state.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Tạo nhóm chat',
              onPressed: _showCreateGroupDialog,
            ),
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
          onTap: (index) {
            switch (index) {
              case 0:
                // Đã ở trang Chat (hiện tại)
                break;
              case 1:
                // Chuyển đến trang Bạn bè
                context.go(AppRouteConstants.friendsPath);
                break;
              case 2:
                // Chuyển đến trang Thông báo
                context.go(AppRouteConstants.notificationsPath);
                break;
              case 3:
                // Chuyển đến trang Profile
                context.go('/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}
