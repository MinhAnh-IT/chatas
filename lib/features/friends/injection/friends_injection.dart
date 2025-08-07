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
