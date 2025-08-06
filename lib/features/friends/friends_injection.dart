import 'package:cloud_firestore/cloud_firestore.dart';

// Data Sources
import 'data/datasources/friend_remote_datasource.dart';

// Repositories
import 'data/repositories/friend_repository_impl.dart';
import 'domain/repositories/friend_repository.dart';

// Use Cases
import 'domain/usecases/get_friends_usecase.dart';
import 'domain/usecases/send_friend_request_usecase.dart';
import 'domain/usecases/accept_friend_request_usecase_new.dart';
import 'domain/usecases/reject_friend_request_usecase.dart';
import 'domain/usecases/remove_friend_usecase_new.dart';
import 'domain/usecases/cancel_friend_request_usecase.dart';
import 'domain/usecases/get_received_friend_requests_usecase.dart';
import 'domain/usecases/get_sent_friend_requests_usecase.dart';
import 'domain/usecases/get_friendship_status_usecase.dart';
import 'domain/usecases/update_friend_online_status_usecase.dart';
import 'domain/usecases/update_last_message_usecase.dart';

// Presentation
import 'presentation/cubit/friends_cubit.dart';
import 'presentation/cubit/friend_requests_cubit.dart';

class FriendsDependencyInjection {
  static FriendRemoteDataSource? _remoteDataSource;
  static FriendRepository? _repository;
  static Map<String, dynamic> _useCases = {};

  static FriendRemoteDataSource get remoteDataSource {
    _remoteDataSource ??= FriendRemoteDataSource(
      firestore: FirebaseFirestore.instance,
    );
    return _remoteDataSource!;
  }

  static FriendRepository get repository {
    _repository ??= FriendRepositoryImpl(remoteDataSource: remoteDataSource);
    return _repository!;
  }

  // Use Cases
  static GetFriendsUseCase get getFriendsUseCase {
    _useCases['getFriends'] ??= GetFriendsUseCase(repository);
    return _useCases['getFriends'];
  }

  static SendFriendRequestUseCase get sendFriendRequestUseCase {
    _useCases['sendFriendRequest'] ??= SendFriendRequestUseCase(repository);
    return _useCases['sendFriendRequest'];
  }

  static AcceptFriendRequestUseCase get acceptFriendRequestUseCase {
    _useCases['acceptFriendRequest'] ??= AcceptFriendRequestUseCase(repository);
    return _useCases['acceptFriendRequest'];
  }

  static RejectFriendRequestUseCase get rejectFriendRequestUseCase {
    _useCases['rejectFriendRequest'] ??= RejectFriendRequestUseCase(repository);
    return _useCases['rejectFriendRequest'];
  }

  static RemoveFriendUseCase get removeFriendUseCase {
    _useCases['removeFriend'] ??= RemoveFriendUseCase(repository);
    return _useCases['removeFriend'];
  }

  static CancelFriendRequestUseCase get cancelFriendRequestUseCase {
    _useCases['cancelFriendRequest'] ??= CancelFriendRequestUseCase(repository);
    return _useCases['cancelFriendRequest'];
  }

  static GetReceivedFriendRequestsUseCase get getReceivedFriendRequestsUseCase {
    _useCases['getReceivedFriendRequests'] ??= GetReceivedFriendRequestsUseCase(
      repository,
    );
    return _useCases['getReceivedFriendRequests'];
  }

  static GetSentFriendRequestsUseCase get getSentFriendRequestsUseCase {
    _useCases['getSentFriendRequests'] ??= GetSentFriendRequestsUseCase(
      repository,
    );
    return _useCases['getSentFriendRequests'];
  }

  static GetFriendshipStatusUseCase get getFriendshipStatusUseCase {
    _useCases['getFriendshipStatus'] ??= GetFriendshipStatusUseCase(repository);
    return _useCases['getFriendshipStatus'];
  }

  static UpdateFriendOnlineStatusUseCase get updateFriendOnlineStatusUseCase {
    _useCases['updateOnlineStatus'] ??= UpdateFriendOnlineStatusUseCase(
      repository,
    );
    return _useCases['updateOnlineStatus'];
  }

  static UpdateLastMessageUseCase get updateLastMessageUseCase {
    _useCases['updateLastMessage'] ??= UpdateLastMessageUseCase(repository);
    return _useCases['updateLastMessage'];
  }

  // Cubits
  static FriendsCubit createFriendsCubit() {
    return FriendsCubit(
      getFriendsUseCase: getFriendsUseCase,
      removeFriendUseCase: removeFriendUseCase,
      updateOnlineStatusUseCase: updateFriendOnlineStatusUseCase,
    );
  }

  static FriendRequestsCubit createFriendRequestsCubit() {
    return FriendRequestsCubit(
      sendFriendRequestUseCase: sendFriendRequestUseCase,
      acceptFriendRequestUseCase: acceptFriendRequestUseCase,
      rejectFriendRequestUseCase: rejectFriendRequestUseCase,
      cancelFriendRequestUseCase: cancelFriendRequestUseCase,
      getReceivedRequestsUseCase: getReceivedFriendRequestsUseCase,
      getSentRequestsUseCase: getSentFriendRequestsUseCase,
    );
  }
}
