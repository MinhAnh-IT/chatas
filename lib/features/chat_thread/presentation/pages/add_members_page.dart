import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../friends/presentation/cubit/friends_list_cubit.dart';
import '../../../friends/data/repositories/friend_repository_impl.dart';
import '../../../friends/data/datasources/friendDataSource.dart';
import '../../../friends/domain/usecases/get_friends_usecase.dart';
import '../../../friends/domain/usecases/block_friend_usecase.dart';
import '../../../friends/domain/entities/friend.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/manage_group_chat_usecase.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../shared/widgets/app_bar.dart';

class AddMembersPage extends StatefulWidget {
  final ChatThread chatThread;
  final VoidCallback? onMembersAdded;

  const AddMembersPage({
    super.key,
    required this.chatThread,
    this.onMembersAdded,
  });

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  late FriendsListCubit _friendsCubit;
  late ManageGroupChatUseCase _manageGroupChatUseCase;
  final Set<String> _selectedFriendIds = {};
  bool _isAdding = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _initializeCubits();
    _loadFriends();
  }

  void _initializeCubits() {
    // Initialize friends cubit
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

    // Initialize group management use case
    final chatThreadRepository = ChatThreadRepositoryImpl();
    _manageGroupChatUseCase = ManageGroupChatUseCase(chatThreadRepository);

    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  void _loadFriends() {
    if (_currentUserId.isNotEmpty) {
      _friendsCubit.loadFriends(_currentUserId);
    }
  }

  /// Check if friend is already in the group
  bool _isFriendAlreadyInGroup(String friendId) {
    // Extract actual friend ID (remove current user prefix)
    final parts = friendId.split('_');
    final actualFriendId = parts.length == 2 ? parts[1] : friendId;
    return widget.chatThread.members.contains(actualFriendId);
  }

  /// Get available friends (not already in group)
  List<Friend> _getAvailableFriends(List<Friend> allFriends) {
    return allFriends
        .where((friend) => !_isFriendAlreadyInGroup(friend.friendId))
        .toList();
  }

  void _toggleFriendSelection(String friendId) {
    setState(() {
      if (_selectedFriendIds.contains(friendId)) {
        _selectedFriendIds.remove(friendId);
      } else {
        _selectedFriendIds.add(friendId);
      }
    });
  }

  Future<void> _addSelectedMembers() async {
    if (_selectedFriendIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một bạn bè')),
      );
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      print(
        'AddMembersPage: Adding ${_selectedFriendIds.length} members to group ${widget.chatThread.id}',
      );

      // Extract actual friend IDs and add them one by one
      for (final friendId in _selectedFriendIds) {
        final parts = friendId.split('_');
        final actualFriendId = parts.length == 2 ? parts[1] : friendId;

        print('AddMembersPage: Adding member: $actualFriendId');
        await _manageGroupChatUseCase.addMember(
          chatThreadId: widget.chatThread.id,
          memberId: actualFriendId,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm ${_selectedFriendIds.length} thành viên vào nhóm',
          ),
        ),
      );

      // Notify parent and navigate back
      widget.onMembersAdded?.call();
      Navigator.pop(context);
    } catch (e) {
      print('AddMembersPage: Error adding members: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _friendsCubit,
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'Thêm thành viên',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (_selectedFriendIds.isNotEmpty)
              TextButton(
                onPressed: _isAdding ? null : _addSelectedMembers,
                child: _isAdding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Thêm (${_selectedFriendIds.length})',
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
            // Current group info
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              child: Row(
                children: [
                  SmartAvatar(
                    imageUrl: widget.chatThread.avatarUrl,
                    radius: 20,
                    fallbackText: widget.chatThread.name,
                    showBorder: true,
                    showShadow: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chatThread.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.chatThread.members.length} thành viên',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selection summary
            if (_selectedFriendIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  children: [
                    Icon(
                      Icons.group_add,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedFriendIds.length} bạn bè đã chọn',
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
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
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
                    final allFriends = state.friends;
                    final availableFriends = _getAvailableFriends(allFriends);

                    if (availableFriends.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tất cả bạn bè đã có trong nhóm',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Không có bạn bè nào để thêm vào nhóm này',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Instructions
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chọn bạn bè để thêm vào nhóm (${availableFriends.length} có thể thêm)',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Friends list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: availableFriends.length,
                            itemBuilder: (context, index) {
                              final friend = availableFriends[index];
                              final isSelected = _selectedFriendIds.contains(
                                friend.friendId,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Card(
                                  elevation: isSelected ? 4 : 1,
                                  child: ListTile(
                                    leading: Stack(
                                      children: [
                                        SmartAvatar(
                                          imageUrl:
                                              '', // Friend entity doesn't have avatarUrl
                                          radius: 20,
                                          fallbackText:
                                              friend.nickName.isNotEmpty
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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          )
                                        : Icon(
                                            Icons.radio_button_unchecked,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    onTap: () =>
                                        _toggleFriendSelection(friend.friendId),
                                    selected: isSelected,
                                    selectedTileColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.3),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _selectedFriendIds.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _isAdding ? null : _addSelectedMembers,
                icon: _isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.group_add),
                label: Text(
                  _isAdding
                      ? 'Đang thêm...'
                      : 'Thêm ${_selectedFriendIds.length} bạn',
                ),
              )
            : null,
      ),
    );
  }
}
