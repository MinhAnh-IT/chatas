import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_users_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/entities/friendRequest.dart';
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

  Future<void> sendFriendRequest(String currentUserId, String toUserId) async {
    try {
      final friendRequest = FriendRequest(
        id: '${currentUserId}_$toUserId',
        fromUserId: currentUserId,
        toUserId: toUserId,
        sentAt: DateTime.now(),
        status: 'pending',
      );
      await sendFriendRequestUseCase.call(friendRequest);
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
