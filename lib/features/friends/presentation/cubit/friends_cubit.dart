import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/friend.dart';
import '../../domain/usecases/get_friends_usecase.dart';
import '../../domain/usecases/remove_friend_usecase_new.dart';
import '../../domain/usecases/update_friend_online_status_usecase.dart';

// States
class FriendsState {
  final bool isLoading;
  final List<Friend> friends;
  final String? error;
  final String? successMessage;

  const FriendsState({
    this.isLoading = false,
    this.friends = const [],
    this.error,
    this.successMessage,
  });

  FriendsState copyWith({
    bool? isLoading,
    List<Friend>? friends,
    String? error,
    String? successMessage,
  }) {
    return FriendsState(
      isLoading: isLoading ?? this.isLoading,
      friends: friends ?? this.friends,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

// Cubit
class FriendsCubit extends Cubit<FriendsState> {
  final GetFriendsUseCase getFriendsUseCase;
  final RemoveFriendUseCase removeFriendUseCase;
  final UpdateFriendOnlineStatusUseCase updateOnlineStatusUseCase;

  FriendsCubit({
    required this.getFriendsUseCase,
    required this.removeFriendUseCase,
    required this.updateOnlineStatusUseCase,
  }) : super(const FriendsState());

  Future<void> loadFriends(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final friends = await getFriendsUseCase(userId);
      emit(state.copyWith(isLoading: false, friends: friends));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> removeFriend(String userId, String friendUserId) async {
    try {
      await removeFriendUseCase(userId, friendUserId);

      // Remove from current list
      final updatedFriends = state.friends
          .where((friend) => friend.friendUserId != friendUserId)
          .toList();

      emit(
        state.copyWith(
          friends: updatedFriends,
          successMessage: 'Đã xóa bạn thành công',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await updateOnlineStatusUseCase(userId, isOnline);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
