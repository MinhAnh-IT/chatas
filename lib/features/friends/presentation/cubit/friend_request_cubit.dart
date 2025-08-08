import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/getReceivedFriendRequests.dart';
import '../../domain/usecases/getSentFriendRequests.dart';
import '../../domain/usecases/acceptFriendRequest.dart';
import '../../domain/usecases/rejectFriendRequest.dart';
import '../../domain/usecases/cancelFriendRequest.dart';
import '../../injection/friends_injection.dart';
import 'friend_request_state.dart';

class FriendRequestCubit extends Cubit<FriendRequestState> {
  final GetReceivedFriendRequests getReceivedFriendRequests;
  final GetSentFriendRequests getSentFriendRequests;
  final AcceptFriendRequest acceptFriendRequest;
  final RejectFriendRequest rejectFriendRequest;
  final CancelFriendRequest cancelFriendRequest;
  final String currentUserId;

  FriendRequestCubit({
    required this.getReceivedFriendRequests,
    required this.getSentFriendRequests,
    required this.acceptFriendRequest,
    required this.rejectFriendRequest,
    required this.cancelFriendRequest,
    required this.currentUserId,
  }) : super(const FriendRequestState());

  /// Tải danh sách lời mời kết bạn nhận được
  Future<void> loadReceivedRequests() async {
    emit(
      state.copyWith(isLoadingReceived: true, clearReceivedRequestsError: true),
    );

    try {
      final requests = await getReceivedFriendRequests(currentUserId);
      emit(
        state.copyWith(receivedRequests: requests, isLoadingReceived: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingReceived: false,
          receivedRequestsError: e.toString(),
        ),
      );
    }
  }

  /// Tải danh sách lời mời kết bạn đã gửi
  Future<void> loadSentRequests() async {
    emit(state.copyWith(isLoadingSent: true, clearSentRequestsError: true));

    try {
      final requests = await getSentFriendRequests(currentUserId);
      emit(state.copyWith(sentRequests: requests, isLoadingSent: false));
    } catch (e) {
      emit(
        state.copyWith(isLoadingSent: false, sentRequestsError: e.toString()),
      );
    }
  }

  /// Chấp nhận lời mời kết bạn
  Future<void> acceptRequest(
    String requestId,
    String senderId,
    String receiverId,
    String senderName,
  ) async {
    emit(state.copyWith(isAccepting: true, clearActionError: true));

    try {
      await acceptFriendRequest(requestId, senderId, receiverId);

      // Gửi thông báo cho người gửi lời mời rằng lời mời đã được chấp nhận
      final notificationService =
          FriendsDependencyInjection.friendNotificationService;
      await notificationService['sendFriendAcceptedNotification']({
        'accepterName': 'Bạn', // TODO: Lấy tên người chấp nhận thực tế
        'accepterId': receiverId,
        'toUserId': senderId, // Gửi thông báo cho người gửi lời mời
      });

      // Cập nhật danh sách sau khi chấp nhận
      final updatedRequests = state.receivedRequests
          .where((request) => request.id != requestId)
          .toList();

      emit(
        state.copyWith(receivedRequests: updatedRequests, isAccepting: false),
      );

      // Hiển thị thông báo thành công (có thể emit event khác nếu cần)
    } catch (e) {
      emit(state.copyWith(isAccepting: false, actionError: e.toString()));
    }
  }

  /// Từ chối lời mời kết bạn
  Future<void> rejectRequest(String requestId, String senderId, String senderName) async {
    emit(state.copyWith(isRejecting: true, clearActionError: true));

    try {
      await rejectFriendRequest(requestId);

      // Gửi thông báo cho người gửi lời mời rằng lời mời đã bị từ chối
      final notificationService =
          FriendsDependencyInjection.friendNotificationService;
      await notificationService['sendFriendRejectedNotification']({
        'rejecterName': 'Người dùng', // TODO: Lấy tên người từ chối thực tế
        'rejecterId': currentUserId,
        'toUserId': senderId, // Gửi thông báo cho người gửi lời mời
      });

      // Cập nhật danh sách sau khi từ chối
      final updatedRequests = state.receivedRequests
          .where((request) => request.id != requestId)
          .toList();

      emit(
        state.copyWith(receivedRequests: updatedRequests, isRejecting: false),
      );
    } catch (e) {
      emit(state.copyWith(isRejecting: false, actionError: e.toString()));
    }
  }

  /// Hủy lời mời kết bạn đã gửi
  Future<void> cancelRequest(String senderId, String receiverId) async {
    emit(state.copyWith(isCanceling: true, clearActionError: true));

    try {
      await cancelFriendRequest(senderId, receiverId);

      // Cập nhật danh sách sau khi hủy
      final updatedRequests = state.sentRequests
          .where(
            (request) =>
                !(request.senderId == senderId &&
                    request.receiverId == receiverId),
          )
          .toList();

      emit(state.copyWith(sentRequests: updatedRequests, isCanceling: false));
    } catch (e) {
      emit(state.copyWith(isCanceling: false, actionError: e.toString()));
    }
  }

  /// Refresh tất cả dữ liệu
  Future<void> refreshAll() async {
    await Future.wait([loadReceivedRequests(), loadSentRequests()]);
  }

  /// Clear errors
  void clearErrors() {
    emit(
      state.copyWith(
        clearReceivedRequestsError: true,
        clearSentRequestsError: true,
        clearActionError: true,
      ),
    );
  }
}
