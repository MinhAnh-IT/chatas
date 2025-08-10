import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/friends_list_cubit.dart';
import '../../domain/entities/friend.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../core/constants/app_route_constants.dart';
import '../widgets/friends_with_chat_provider.dart';

class FriendsListPage extends StatefulWidget {
  final String currentUserId;

  const FriendsListPage({Key? key, required this.currentUserId})
    : super(key: key);

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage>
    with ChatOpeningMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FriendsListCubit>().loadFriends(widget.currentUserId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () {
              context.go(AppRouteConstants.friendRequestsPath);
            },
            tooltip: 'Lời mời kết bạn',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouteConstants.friendSearchPath);
              },
              icon: const Icon(Icons.person_add, color: Colors.blue),
              label: const Text(
                'Tìm bạn mới',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FriendsListCubit>().refreshFriends(
                widget.currentUserId,
              );
            },
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bạn bè...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                context.read<FriendsListCubit>().searchFriends(query);
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<FriendsListCubit, FriendsState>(
              listener: (context, state) {
                if (state is FriendsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                if (state is FriendsLoaded && state.successMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.successMessage!),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<FriendsListCubit>().clearMessage();
                }
              },
              builder: (context, state) {
                if (state is FriendsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is FriendsLoaded) {
                  if (state.friends.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    itemCount: state.friends.length,
                    itemBuilder: (context, index) {
                      final friend = state.friends[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              friend.nickName.isNotEmpty
                                  ? friend.nickName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            friend.nickName.isNotEmpty
                                ? friend.nickName
                                : 'Người dùng',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thêm vào: ${_formatDate(friend.addAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              if (friend.isBlock)
                                const Text(
                                  'Đã chặn',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  friend.isBlock
                                      ? Icons.block
                                      : Icons.block_outlined,
                                  color: friend.isBlock
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () => _showBlockDialog(friend),
                                tooltip: friend.isBlock ? 'Bỏ chặn' : 'Chặn',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chat,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _openChat(friend),
                                tooltip: 'Nhắn tin',
                              ),
                            ],
                          ),
                          onTap: () => _openChat(friend),
                        ),
                      );
                    },
                  );
                } else if (state is FriendsError) {
                  return _buildErrorState(state.message);
                }
                return const Center(child: Text('Khởi tạo danh sách bạn bè'));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNavigation(
        currentIndex: 1, // Friends tab is index 1
        onTap: (index) {
          switch (index) {
            case 0:
              // Chuyển đến trang Chat
              context.go('/');
              break;
            case 1:
              // Đã ở trang Bạn bè (hiện tại)
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text(
            'Chưa có bạn bè',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hãy kết bạn với mọi người để bắt đầu trò chuyện',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.go(AppRouteConstants.friendSearchPath);
            },
            icon: const Icon(Icons.person_search, color: Colors.white),
            label: const Text(
              'Tìm kiếm bạn bè',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Đã có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FriendsListCubit>().refreshFriends(
                widget.currentUserId,
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(Friend friend) {
    final isBlocked = friend.isBlock;
    final actionText = isBlocked ? 'Bỏ chặn' : 'Chặn';
    final actionColor = isBlocked ? Colors.green : Colors.red;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$actionText bạn bè'),
        content: Text(
          isBlocked
              ? 'Bạn có chắc chắn muốn bỏ chặn ${friend.nickName}?'
              : 'Bạn có chắc chắn muốn chặn ${friend.nickName}?',
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: Text(actionText, style: TextStyle(color: actionColor)),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FriendsListCubit>().toggleBlockFriend(
                widget.currentUserId,
                friend.friendId,
              );
            },
          ),
        ],
      ),
    );
  }

  void _openChat(Friend friend) {
    openChatWithFriend(context, friend, widget.currentUserId);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      return 'Hôm nay';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
