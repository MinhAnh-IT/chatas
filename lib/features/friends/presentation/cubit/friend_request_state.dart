import 'package:equatable/equatable.dart';
import '../../domain/entities/friendRequest.dart';

class FriendRequestState extends Equatable {
  final List<FriendRequest> receivedRequests;
  final List<FriendRequest> sentRequests;
  final bool isLoadingReceived;
  final bool isLoadingSent;
  final bool isAccepting;
  final bool isRejecting;
  final bool isCanceling;
  final String? receivedRequestsError;
  final String? sentRequestsError;
  final String? actionError;

  const FriendRequestState({
    this.receivedRequests = const [],
    this.sentRequests = const [],
    this.isLoadingReceived = false,
    this.isLoadingSent = false,
    this.isAccepting = false,
    this.isRejecting = false,
    this.isCanceling = false,
    this.receivedRequestsError,
    this.sentRequestsError,
    this.actionError,
  });

  FriendRequestState copyWith({
    List<FriendRequest>? receivedRequests,
    List<FriendRequest>? sentRequests,
    bool? isLoadingReceived,
    bool? isLoadingSent,
    bool? isAccepting,
    bool? isRejecting,
    bool? isCanceling,
    String? receivedRequestsError,
    String? sentRequestsError,
    String? actionError,
    bool clearReceivedRequestsError = false,
    bool clearSentRequestsError = false,
    bool clearActionError = false,
  }) {
    return FriendRequestState(
      receivedRequests: receivedRequests ?? this.receivedRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      isLoadingReceived: isLoadingReceived ?? this.isLoadingReceived,
      isLoadingSent: isLoadingSent ?? this.isLoadingSent,
      isAccepting: isAccepting ?? this.isAccepting,
      isRejecting: isRejecting ?? this.isRejecting,
      isCanceling: isCanceling ?? this.isCanceling,
      receivedRequestsError: clearReceivedRequestsError
          ? null
          : (receivedRequestsError ?? this.receivedRequestsError),
      sentRequestsError: clearSentRequestsError
          ? null
          : (sentRequestsError ?? this.sentRequestsError),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
    receivedRequests,
    sentRequests,
    isLoadingReceived,
    isLoadingSent,
    isAccepting,
    isRejecting,
    isCanceling,
    receivedRequestsError,
    sentRequestsError,
    actionError,
  ];
}
