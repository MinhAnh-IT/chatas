import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../friends/presentation/cubit/friends_list_cubit.dart';
import '../../../friends/data/repositories/friend_repository_impl.dart';
import '../../../friends/data/datasources/friendDataSource.dart';
import '../../../friends/domain/usecases/get_friends_usecase.dart';
import '../../../friends/domain/usecases/block_friend_usecase.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../domain/usecases/create_group_chat_usecase.dart';
import '../../domain/usecases/find_or_create_chat_thread_usecase.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_route_constants.dart';

class FriendSelectionPage extends StatefulWidget {
  final bool isGroupChat;
  final VoidCallback? onCreateChat;

  const FriendSelectionPage({
    super.key,
    required this.isGroupChat,
    this.onCreateChat,
  });

  @override
  State<FriendSelectionPage> createState() => _FriendSelectionPageState();
}

class _FriendSelectionPageState extends State<FriendSelectionPage> {
  late FriendsListCubit _friendsCubit;
  late CreateGroupChatUseCase _createGroupChatUseCase;
  late FindOrCreateChatThreadUseCase _findOrCreateChatThreadUseCase;
  final Set<String> _selectedFriendIds = {};
  final TextEditingController _groupNameController = TextEditingController();
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _initializeCubit();
    _loadFriends();
  }

  void _initializeCubit() {
    final remoteDataSource = FriendRemoteDataSource();
    final friendRepository = FriendRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final getFriendsUseCase = GetFriendsUseCase(friendRepository);
    final blockFriendUseCase = BlockFriendUseCase(friendRepository);

    _friendsCubit = FriendsListCubit(
      getFriendsUseCase: getFriendsUseCase,
      blockFriendUseCase: blockFriendUseCase,
    );

    // Initialize chat thread use cases
    final chatThreadRepository = ChatThreadRepositoryImpl();
    _createGroupChatUseCase = CreateGroupChatUseCase(chatThreadRepository);
    _findOrCreateChatThreadUseCase = FindOrCreateChatThreadUseCase(
      chatThreadRepository,
    );
  }

  void _loadFriends() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isNotEmpty) {
      _friendsCubit.loadFriends(currentUserId);
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _toggleFriendSelection(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        if (widget.isGroupChat || _selectedFriendIds.isEmpty) {
          _selectedFriendIds.add(friendId);
        } else {
          // For 1-on-1 chat, only allow one selection
          _selectedFriendIds.clear();
          _selectedFriendIds.add(friendId);
        }
      }
    });
  }

  void _showGroupNameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tên nhóm chat'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(
            hintText: 'Nhập tên nhóm...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createChat();
            },
            child: const Text('Tạo nhóm'),
          ),
        ],
      ),
    );
  }

  Future<void> _createChat() async {
    if (_selectedFriendIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một bạn bè')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (widget.isGroupChat) {
        final groupName = _groupNameController.text.trim();
        if (groupName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng nhập tên nhóm')),
          );
          return;
        }

        // Extract actual friend IDs (remove current user prefix)
        final memberIds = _selectedFriendIds.map((friendId) {
          final parts = friendId.split('_');
          return parts.length == 2 ? parts[1] : friendId;
        }).toList();

        // Create group chat
        final chatThreadId = await _createGroupChatUseCase.call(
          groupName: groupName,
          memberIds: memberIds,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tạo nhóm "$groupName" thành công!')),
        );

        // Navigate to the new group chat
        final route = AppRouteConstants.chatMessageRoute(
          chatThreadId,
          currentUserId: currentUserId,
          otherUserName: groupName,
        );
        context.go(route);
      } else {
        // Create 1-on-1 chat
        final friendId = _selectedFriendIds.first;
        final parts = friendId.split('_');
        final actualFriendId = parts.length == 2 ? parts[1] : friendId;

        // Use existing use case for 1-on-1 chat with forceCreateNew = true
        // This ensures we create a new thread even if a hidden one exists
        final chatThread = await _findOrCreateChatThreadUseCase.call(
          currentUserId: currentUserId,
          friendId: actualFriendId,
          friendName: 'Bạn bè', // Default name, will be updated from profile
          friendAvatarUrl: '',
          forceCreateNew: true, // Always create new thread
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tạo chat thành công!')));

        // Navigate to the chat
        final route = AppRouteConstants.chatMessageRoute(
          chatThread.id,
          currentUserId: currentUserId,
          otherUserName: chatThread.name,
        );
        context.go(route);
      }

      // Call callback and navigate back
      widget.onCreateChat?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  void _handleCreateButton() {
    if (widget.isGroupChat) {
      _showGroupNameDialog();
    } else {
      _createChat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _friendsCubit,
      child: Scaffold(
        appBar: CommonAppBar(
          title: widget.isGroupChat ? 'Tạo nhóm chat' : 'Chọn bạn bè',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_selectedFriendIds.isNotEmpty)
              TextButton(
                onPressed: _isCreating ? null : _handleCreateButton,
                child: _isCreating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isGroupChat ? 'Tiếp tục' : 'Tạo chat',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Selection summary
            if (_selectedFriendIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      widget.isGroupChat ? Icons.group : Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedFriendIds.length} ${widget.isGroupChat ? 'thành viên' : 'bạn'} đã chọn',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            // Friends list
            Expanded(
              child: BlocBuilder<FriendsListCubit, FriendsState>(
                builder: (context, state) {
                  if (state is FriendsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FriendsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFriends,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is FriendsLoaded) {
                    final friends = state.friends;

                    if (friends.isEmpty) {
                      return const Center(
                        child: Text('Bạn chưa có bạn bè nào'),
                      );
                    }

                    return ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        final isSelected = _selectedFriendIds.contains(
                          friend.friendId,
                        );

                        return ListTile(
                          leading: Stack(
                            children: [
                              SmartAvatar(
                                imageUrl:
                                    '', // Friend entity doesn't have avatarUrl
                                radius: 20,
                                fallbackText: friend.nickName.isNotEmpty
                                    ? friend.nickName
                                    : 'U',
                                showBorder: true,
                                showShadow: true,
                              ),
                              if (isSelected)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            friend.nickName.isNotEmpty
                                ? friend.nickName
                                : 'Người dùng',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: !friend.isBlock
                              ? Text(
                                  'Bạn bè',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontSize: 12,
                                  ),
                                )
                              : Text(
                                  'Đã chặn',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 12,
                                  ),
                                ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => _toggleFriendSelection(friend.friendId),
                          selected: isSelected,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.3),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
