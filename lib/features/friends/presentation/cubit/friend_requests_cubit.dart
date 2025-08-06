import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/friendRequest.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/usecases/accept_friend_request_usecase_new.dart';
import '../../domain/usecases/reject_friend_request_usecase.dart';
import '../../domain/usecases/cancel_friend_request_usecase.dart';
import '../../domain/usecases/get_received_friend_requests_usecase.dart';
import '../../domain/usecases/get_sent_friend_requests_usecase.dart';

// States
class FriendRequestsState {
  final bool isLoading;
  final List<FriendRequest> receivedRequests;
  final List<FriendRequest> sentRequests;
  final String? error;
  final String? successMessage;

  const FriendRequestsState({
    this.isLoading = false,
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.error,
    this.successMessage,
  });

  FriendRequestsState copyWith({
    bool? isLoading,
    List<FriendRequest>? receivedRequests,
    List<FriendRequest>? sentRequests,
    String? error,
    String? successMessage,
  }) {
    return FriendRequestsState(
      isLoading: isLoading ?? this.isLoading,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

// Cubit
class FriendRequestsCubit extends Cubit<FriendRequestsState> {
  final SendFriendRequestUseCase sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase rejectFriendRequestUseCase;
  final CancelFriendRequestUseCase cancelFriendRequestUseCase;
  final GetReceivedFriendRequestsUseCase getReceivedRequestsUseCase;
  final GetSentFriendRequestsUseCase getSentRequestsUseCase;

  FriendRequestsCubit({
    required this.sendFriendRequestUseCase,
    required this.acceptFriendRequestUseCase,
    required this.rejectFriendRequestUseCase,
    required this.cancelFriendRequestUseCase,
    required this.getReceivedRequestsUseCase,
    required this.getSentRequestsUseCase,
  }) : super(const FriendRequestsState());

  Future<void> loadReceivedRequests(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final requests = await getReceivedRequestsUseCase(userId);
      emit(state.copyWith(isLoading: false, receivedRequests: requests));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSentRequests(String userId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final requests = await getSentRequestsUseCase(userId);
      emit(state.copyWith(isLoading: false, sentRequests: requests));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> sendFriendRequest(FriendRequest request) async {
    try {
      await sendFriendRequestUseCase(request);
      emit(
        state.copyWith(
          successMessage: 'Đã gửi lời mời kết bạn',
          sentRequests: [...state.sentRequests, request],
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await acceptFriendRequestUseCase(requestId);

      // Remove from received requests
      final updatedRequests = state.receivedRequests
          .where((request) => request.id != requestId)
          .toList();

      emit(
        state.copyWith(
          receivedRequests: updatedRequests,
          successMessage: 'Đã chấp nhận lời mời kết bạn',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await rejectFriendRequestUseCase(requestId);

      // Remove from received requests
      final updatedRequests = state.receivedRequests
          .where((request) => request.id != requestId)
          .toList();

      emit(
        state.copyWith(
          receivedRequests: updatedRequests,
          successMessage: 'Đã từ chối lời mời kết bạn',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    try {
      await cancelFriendRequestUseCase(requestId);

      // Remove from sent requests
      final updatedRequests = state.sentRequests
          .where((request) => request.id != requestId)
          .toList();

      emit(
        state.copyWith(
          sentRequests: updatedRequests,
          successMessage: 'Đã hủy lời mời kết bạn',
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void clearMessages() {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
