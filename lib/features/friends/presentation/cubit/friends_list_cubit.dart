import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/block_friend_usecase.dart';

// States
abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<Friend> friends;
  final String? successMessage;

  const FriendsLoaded({required this.friends, this.successMessage});

  @override
  List<Object?> get props => [friends, successMessage];

  FriendsLoaded copyWith({List<Friend>? friends, String? successMessage}) {
    return FriendsLoaded(
      friends: friends ?? this.friends,
      successMessage: successMessage,
    );
  }
}

class FriendsError extends FriendsState {
  final String message;
  final List<Friend>? previousFriends;

  const FriendsError(this.message, {this.previousFriends});

  @override
  List<Object?> get props => [message, previousFriends];
}

// Cubit
class FriendsListCubit extends Cubit<FriendsState> {
  final GetFriendsUseCase getFriendsUseCase;
  final BlockFriendUseCase blockFriendUseCase;

  FriendsListCubit({
    required this.getFriendsUseCase,
    required this.blockFriendUseCase,
  }) : super(FriendsInitial());

  /// Lấy danh sách bạn bè
  Future<void> loadFriends(String currentUserId) async {
    emit(FriendsLoading());

    try {
      final friends = await getFriendsUseCase.call(currentUserId);
      emit(FriendsLoaded(friends: friends));
    } catch (e) {
      emit(FriendsError('Không thể tải danh sách bạn bè: ${e.toString()}'));
    }
  }

  /// Block bạn bè
  Future<void> blockFriend(String currentUserId, String friendId) async {
    if (state is! FriendsLoaded) return;

    final currentFriends = (state as FriendsLoaded).friends;

    try {
      // Extract actualFriendId từ friendId (format: userId_actualFriendId)
      final parts = friendId.split('_');
      if (parts.length != 2) {
        throw Exception('Invalid friendId format');
      }
      final actualFriendId = parts[1];

      await blockFriendUseCase.call(currentUserId, actualFriendId, true);

      // Cập nhật danh sách local - loại bỏ người bạn bị block
      final updatedFriends = currentFriends
          .where((friend) => friend.friendId != friendId)
          .toList();

      emit(
        FriendsLoaded(
          friends: updatedFriends,
          successMessage: 'Đã chặn bạn bè thành công',
        ),
      );
    } catch (e) {
      emit(
        FriendsError(
          'Không thể chặn bạn bè: ${e.toString()}',
          previousFriends: currentFriends,
        ),
      );
    }
  }

  /// Unblock bạn bè (để có thể hiển thị lại trong danh sách)
  Future<void> unblockFriend(String currentUserId, String friendId) async {
    try {
      // Extract actualFriendId từ friendId (format: userId_actualFriendId)
      final parts = friendId.split('_');
      if (parts.length != 2) {
        throw Exception('Invalid friendId format');
      }
      final actualFriendId = parts[1];

      await blockFriendUseCase.call(currentUserId, actualFriendId, false);

      // Reload lại danh sách để hiển thị người bạn đã unblock
      await loadFriends(currentUserId);

      if (state is FriendsLoaded) {
        final currentState = state as FriendsLoaded;
        emit(
          currentState.copyWith(successMessage: 'Đã bỏ chặn bạn bè thành công'),
        );
      }
    } catch (e) {
      emit(FriendsError('Không thể bỏ chặn bạn bè: ${e.toString()}'));
    }
  }

  /// Toggle block/unblock bạn bè
  Future<void> toggleBlockFriend(String currentUserId, String friendId) async {
    if (state is! FriendsLoaded) return;

    final currentFriends = (state as FriendsLoaded).friends;
    final friend = currentFriends.firstWhere(
      (f) => f.friendId == friendId,
      orElse: () => throw Exception('Không tìm thấy bạn bè'),
    );

    try {
      // Extract actualFriendId từ friendId (format: userId_actualFriendId)
      final parts = friendId.split('_');
      if (parts.length != 2) {
        throw Exception('Invalid friendId format');
      }
      final actualFriendId = parts[1];

      final newBlockStatus = !friend.isBlock;
      await blockFriendUseCase.call(currentUserId, actualFriendId, newBlockStatus);

      // Cập nhật friend trong danh sách
      final updatedFriends = currentFriends.map((f) {
        if (f.friendId == friendId) {
          return Friend(
            friendId: f.friendId,
            nickName: f.nickName,
            addAt: f.addAt,
            isBlock: newBlockStatus,
          );
        }
        return f;
      }).toList();

      final message = newBlockStatus 
          ? 'Đã chặn ${friend.nickName} thành công'
          : 'Đã bỏ chặn ${friend.nickName} thành công';

      emit(
        FriendsLoaded(
          friends: updatedFriends,
          successMessage: message,
        ),
      );
    } catch (e) {
      emit(FriendsError('Không thể thay đổi trạng thái chặn: ${e.toString()}'));
    }
  }

  /// Refresh danh sách
  Future<void> refreshFriends(String currentUserId) async {
    await loadFriends(currentUserId);
  }

  /// Xóa message
  void clearMessage() {
    if (state is FriendsLoaded) {
      final currentState = state as FriendsLoaded;
      emit(FriendsLoaded(friends: currentState.friends));
    }
  }

  /// Tìm kiếm bạn bè theo nickname
  void searchFriends(String query) {
    if (state is! FriendsLoaded) return;

    final allFriends = (state as FriendsLoaded).friends;

    if (query.isEmpty) {
      emit(FriendsLoaded(friends: allFriends));
      return;
    }

    final filteredFriends = allFriends
        .where(
          (friend) =>
              friend.nickName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    emit(FriendsLoaded(friends: filteredFriends));
  }
}
