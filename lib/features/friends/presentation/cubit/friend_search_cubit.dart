import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/entities/friendRequest.dart';
import '../../injection/friends_injection.dart';
import 'friend_search_state.dart';

class FriendSearchCubit extends Cubit<FriendSearchState> {
  final SearchUsersUseCase searchUsersUseCase;
  final SendFriendRequestUseCase sendFriendRequestUseCase;

  FriendSearchCubit({
    required this.searchUsersUseCase,
    required this.sendFriendRequestUseCase,
  }) : super(FriendSearchInitial());

  Future<void> searchUsers(String query, String currentUserId) async {
    emit(FriendSearchLoading());
    try {
      print('DEBUG: Searching for: $query, currentUserId: $currentUserId');
      final users = await searchUsersUseCase.call(query, currentUserId);
      print('DEBUG: Found ${users.length} users');
      print('DEBUG: Users data: $users');
      emit(FriendSearchLoaded(users: users));
    } catch (e) {
      print('DEBUG: Search error: $e');
      emit(FriendSearchError('Không thể tìm kiếm người dùng: ${e.toString()}'));
    }
  }

  Future<void> sendFriendRequest(
    String currentUserId,
    String toUserId,
    String toUserName,
  ) async {
    try {
      final friendRequest = FriendRequest(
        id: '${currentUserId}_$toUserId',
        fromUserId: currentUserId,
        toUserId: toUserId,
        sentAt: DateTime.now(),
        status: 'pending',
      );
      await sendFriendRequestUseCase.call(friendRequest);

      // Gửi thông báo cho người nhận lời mời
      final notificationService =
          FriendsDependencyInjection.friendNotificationService;

      // Lấy tên thực của người gửi từ Firestore
      String fromUserName = 'Người dùng'; // Default fallback
      try {
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .get();
        if (currentUserDoc.exists) {
          final userData = currentUserDoc.data() as Map<String, dynamic>;
          fromUserName =
              userData['fullName'] ?? userData['displayName'] ?? 'Người dùng';
        }
      } catch (e) {
        // Sử dụng default name nếu có lỗi
      }

      await notificationService['sendFriendRequestNotification']({
        'fromUserName': fromUserName,
        'fromUserId': currentUserId,
        'toUserId':
            toUserId, // Thêm ID người nhận để gửi thông báo cho đúng người
      });

      if (state is FriendSearchLoaded) {
        final currentUsers = (state as FriendSearchLoaded).users;
        final updatedUsers = currentUsers
            .where((user) => user['userId'] != toUserId)
            .toList();
        emit(FriendSearchLoaded(users: updatedUsers));
      }
    } catch (e) {
      emit(FriendSearchError('Không thể gửi lời mời kết bạn: ${e.toString()}'));
    }
  }
}
