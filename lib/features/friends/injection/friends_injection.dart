import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/friendDataSource.dart';
import '../data/repositories/friend_repository_impl.dart';
import '../domain/usecases/get_friends_usecase.dart';
import '../domain/usecases/block_friend_usecase.dart';
import '../domain/usecases/search_users_usecase.dart';
import '../domain/usecases/send_friend_request_usecase.dart';
import '../domain/usecases/getReceivedFriendRequests.dart';
import '../domain/usecases/getSentFriendRequests.dart';
import '../domain/usecases/acceptFriendRequest.dart';
import '../domain/usecases/rejectFriendRequest.dart';
import '../domain/usecases/cancelFriendRequest.dart';
import '../presentation/cubit/friends_list_cubit.dart';
import '../presentation/cubit/friend_search_cubit.dart';
import '../presentation/cubit/friend_request_cubit.dart';
import '../services/fcm_push_service.dart';

class FriendsDependencyInjection {
  static late FriendRemoteDataSource _dataSource;
  static late FriendRepositoryImpl _repository;

  static late GetFriendsUseCase _getFriendsUseCase;
  static late BlockFriendUseCase _blockFriendUseCase;
  static late SearchUsersUseCase _searchUsersUseCase;
  static late SendFriendRequestUseCase _sendFriendRequestUseCase;
  static late GetReceivedFriendRequests _getReceivedFriendRequests;
  static late GetSentFriendRequests _getSentFriendRequests;
  static late AcceptFriendRequest _acceptFriendRequest;
  static late RejectFriendRequest _rejectFriendRequest;
  static late CancelFriendRequest _cancelFriendRequest;

  // Notification service getter - tạo instance mới mỗi lần gọi
  static dynamic get friendNotificationService {
    // Lazy loading để tránh circular dependency
    try {
      return {
        'sendFriendRequestNotification': (Map<String, dynamic> params) async {
          final String fromUserName = params['fromUserName'] ?? 'Người dùng';
          final String fromUserId = params['fromUserId'] ?? '';
          final String toUserId = params['toUserId'] ?? '';

          print('📤 [FCM Real] Gửi friend request notification:');
          print('   From: $fromUserName ($fromUserId)');
          print('   To: $toUserId');

          try {
            // Gửi FCM push notification đến người nhận (User B)
            final success = await FCMPushService.sendNotificationToUser(
              toUserId: toUserId,
              title: 'Lời mời kết bạn mới',
              body: '$fromUserName đã gửi lời mời kết bạn cho bạn',
              data: {
                'fromUserId': fromUserId,
                'fromUserName': fromUserName,
                'action': 'friend_request',
                'type': 'friend_notification',
              },
            );

            if (success) {
              print('✅ Đã gửi FCM notification cho user $toUserId');
            } else {
              print('❌ Thất bại gửi FCM notification cho user $toUserId');

              // Fallback: Log chi tiết để debug
              print('🔍 Debug: Kiểm tra FCM token của user $toUserId');
            }
          } catch (e) {
            print('❌ Exception khi gửi friend request notification: $e');
          }
        },
        'sendFriendAcceptedNotification': (Map<String, dynamic> params) async {
          final String accepterName = params['accepterName'] ?? 'Người dùng';
          final String accepterId = params['accepterId'] ?? '';
          final String toUserId = params['toUserId'] ?? '';

          print('📤 [FCM Real] Gửi friend accepted notification:');
          print('   Accepter: $accepterName ($accepterId)');
          print('   To: $toUserId');

          try {
            // Gửi FCM push notification đến người gửi lời mời ban đầu
            final success = await FCMPushService.sendNotificationToUser(
              toUserId: toUserId,
              title: 'Lời mời kết bạn đã được chấp nhận',
              body: '$accepterName đã chấp nhận lời mời kết bạn của bạn',
              data: {
                'fromUserId': accepterId,
                'accepterName': accepterName,
                'action': 'friend_accepted',
                'type': 'friend_notification',
              },
            );

            if (success) {
              print('✅ Đã gửi FCM accepted notification cho user $toUserId');
            } else {
              print(
                '❌ Thất bại gửi FCM accepted notification cho user $toUserId',
              );
            }
          } catch (e) {
            print('❌ Exception khi gửi friend accepted notification: $e');
          }
        },
        'sendFriendRejectedNotification': (Map<String, dynamic> params) async {
          final String rejecterName = params['rejecterName'] ?? 'Người dùng';
          final String rejecterId = params['rejecterId'] ?? '';
          final String toUserId = params['toUserId'] ?? '';

          print('📤 [FCM Real] Gửi friend rejected notification:');
          print('   Rejecter: $rejecterName ($rejecterId)');
          print('   To: $toUserId');

          try {
            // Gửi FCM push notification đến người gửi lời mời ban đầu
            final success = await FCMPushService.sendNotificationToUser(
              toUserId: toUserId,
              title: 'Lời mời kết bạn đã bị từ chối',
              body: '$rejecterName đã từ chối lời mời kết bạn của bạn',
              data: {
                'fromUserId': rejecterId,
                'rejecterName': rejecterName,
                'action': 'friend_rejected',
                'type': 'friend_notification',
              },
            );

            if (success) {
              print('✅ Đã gửi FCM rejected notification cho user $toUserId');
            } else {
              print(
                '❌ Thất bại gửi FCM rejected notification cho user $toUserId',
              );
            }
          } catch (e) {
            print('❌ Exception khi gửi friend rejected notification: $e');
          }
        },
      };
    } catch (e) {
      print('Lỗi tạo friend notification service: $e');
      return null;
    }
  }

  static void init() {
    // Data layer
    _dataSource = FriendRemoteDataSource(firestore: FirebaseFirestore.instance);
    _repository = FriendRepositoryImpl(remoteDataSource: _dataSource);

    // Use cases
    _getFriendsUseCase = GetFriendsUseCase(_repository);
    _blockFriendUseCase = BlockFriendUseCase(_repository);
    _searchUsersUseCase = SearchUsersUseCase(_repository);
    _sendFriendRequestUseCase = SendFriendRequestUseCase(_repository);
    _getReceivedFriendRequests = GetReceivedFriendRequests(_repository);
    _getSentFriendRequests = GetSentFriendRequests(_repository);
    _acceptFriendRequest = AcceptFriendRequest(_repository);
    _rejectFriendRequest = RejectFriendRequest(_repository);
    _cancelFriendRequest = CancelFriendRequest(_repository);
  }

  // Getters
  static FriendRepositoryImpl get repository => _repository;
  static GetFriendsUseCase get getFriendsUseCase => _getFriendsUseCase;
  static BlockFriendUseCase get blockFriendUseCase => _blockFriendUseCase;
  static SearchUsersUseCase get searchUsersUseCase => _searchUsersUseCase;
  static SendFriendRequestUseCase get sendFriendRequestUseCase =>
      _sendFriendRequestUseCase;

  // Cubit factory
  static FriendsListCubit createFriendsListCubit() {
    return FriendsListCubit(
      getFriendsUseCase: _getFriendsUseCase,
      blockFriendUseCase: _blockFriendUseCase,
    );
  }

  static FriendSearchCubit createFriendSearchCubit() {
    return FriendSearchCubit(
      searchUsersUseCase: _searchUsersUseCase,
      sendFriendRequestUseCase: _sendFriendRequestUseCase,
    );
  }

  static FriendRequestCubit createFriendRequestCubit(String currentUserId) {
    return FriendRequestCubit(
      getReceivedFriendRequests: _getReceivedFriendRequests,
      getSentFriendRequests: _getSentFriendRequests,
      acceptFriendRequest: _acceptFriendRequest,
      rejectFriendRequest: _rejectFriendRequest,
      cancelFriendRequest: _cancelFriendRequest,
      currentUserId: currentUserId,
    );
  }
}
