import 'package:flutter/material.dart';
import '../../domain/entities/friendRequest.dart';
import '../../domain/usecases/accept_friend_request_usecase.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../data/repositories/friend_repository_impl.dart';

class FriendRequestsScreen extends StatefulWidget {
  final String currentUserId;
  final FriendRepositoryImpl repository;

  const FriendRequestsScreen({
    Key? key,
    required this.currentUserId,
    required this.repository,
  }) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<FriendRequest> friendRequests = [];
  bool isLoading = true;

  late AcceptFriendRequestUseCase acceptUseCase;
  late RejectFriendRequestUseCase rejectUseCase;

  @override
  void initState() {
    super.initState();
    acceptUseCase = AcceptFriendRequestUseCase(widget.repository);
    rejectUseCase = RejectFriendRequestUseCase(widget.repository);
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    setState(() => isLoading = true);
    try {
      final requests = await widget.repository.getReceivedFriendRequests(
        widget.currentUserId,
      );
      setState(() {
        friendRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar('Lỗi khi tải lời mời kết bạn: $e');
    }
  }

  Future<void> _acceptFriendRequest(FriendRequest request) async {
    try {
      await acceptUseCase(request.id, request.senderId, request.receiverId);
      _showSuccessSnackBar('Đã chấp nhận lời mời kết bạn');
      _loadFriendRequests();
    } catch (e) {
      _showErrorSnackBar('Lỗi khi chấp nhận lời mời: $e');
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      await rejectUseCase(requestId);
      _showSuccessSnackBar('Đã từ chối lời mời kết bạn');
      _loadFriendRequests();
    } catch (e) {
      _showErrorSnackBar('Lỗi khi từ chối lời mời: $e');
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
        title: const Text('Lời mời kết bạn'),
        actions: [
          IconButton(
            onPressed: _loadFriendRequests,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendRequests.isEmpty
          ? const Center(
              child: Text(
                'Không có lời mời kết bạn nào',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: friendRequests.length,
              itemBuilder: (context, index) {
                final request = friendRequests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(request.senderId[0].toUpperCase()),
                    ),
                    title: Text('User ${request.senderId}'),
                    subtitle: Text(
                      'Gửi lời mời vào ${_formatDate(request.createdAt)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => _rejectFriendRequest(request.id),
                          child: const Text(
                            'Từ chối',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _acceptFriendRequest(request),
                          child: const Text('Chấp nhận'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
