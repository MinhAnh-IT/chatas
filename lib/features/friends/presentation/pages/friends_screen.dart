import 'package:flutter/material.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friendRequest.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/usecases/accept_friend_request_usecase.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../domain/usecases/remove_friend_usecase.dart';

class FriendsScreen extends StatefulWidget {
  final String currentUserId;
  final GetFriendsUseCase getFriendsUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final RemoveFriendUseCase removeFriendUseCase;

  const FriendsScreen({
    Key? key,
    required this.currentUserId,
    required this.getFriendsUseCase,
    required this.sendFriendRequestUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.removeFriendUseCase,
  }) : super(key: key);

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<Friend> friends = [];
  List<FriendRequest> friendRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => isLoading = true);
    try {
      final loadedFriends = await widget.getFriendsUseCase(
        widget.currentUserId,
      );
      setState(() {
        friends = loadedFriends;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Lỗi khi tải danh sách bạn bè: $e');
    }
  }

  Future<void> _sendFriendRequest(String receiverId) async {
    try {
      final request = FriendRequest(
        id: '${widget.currentUserId}_$receiverId',
        senderId: widget.currentUserId,
        receiverId: receiverId,
        createdAt: DateTime.now(),
        status: 'pending',
      );
      await widget.sendFriendRequestUseCase(request);
      _showSuccessSnackBar('Đã gửi lời mời kết bạn');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi gửi lời mời: $e');
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String senderId) async {
    try {
      await widget.acceptFriendRequestUseCase(
        requestId,
        senderId,
        widget.currentUserId,
      );
      _showSuccessSnackBar('Đã chấp nhận lời mời kết bạn');
      _loadFriends();
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chấp nhận lời mời: $e');
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      await widget.rejectFriendRequestUseCase(requestId);
      _showSuccessSnackBar('Đã từ chối lời mời kết bạn');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi từ chối lời mời: $e');
    }
  }

  Future<void> _removeFriend(String friendId) async {
    try {
      await widget.removeFriendUseCase(widget.currentUserId, friendId);
      _showSuccessSnackBar('Đã xóa bạn bè');
      _loadFriends();
    } catch (e) {
      _showErrorSnackBar('Lỗi khi xóa bạn: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bạn bè'),
        actions: [
          IconButton(onPressed: _loadFriends, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? const Center(
              child: Text('Chưa có bạn bè nào', style: TextStyle(fontSize: 16)),
            )
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(friend.friendId[0].toUpperCase()),
                    ),
                    title: Text('User ${friend.friendId}'),
                    subtitle: Text(
                      'Kết bạn từ ${_formatDate(friend.createdAt)}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'remove') {
                          _confirmRemoveFriend(friend.friendId);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.person_remove, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Xóa bạn',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendDialog(),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _confirmRemoveFriend(String friendId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa bạn bè này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(friendId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bạn'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ID người dùng',
            hintText: 'Nhập ID người dùng muốn kết bạn',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _sendFriendRequest(controller.text);
              }
            },
            child: const Text('Gửi lời mời'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
