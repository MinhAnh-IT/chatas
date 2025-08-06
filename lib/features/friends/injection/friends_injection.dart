import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/friendDataSource.dart';
import '../data/repositories/friend_repository_impl.dart';
import '../domain/usecases/get_friends_usecase.dart';
import '../domain/usecases/send_friend_request_usecase.dart';
import '../domain/usecases/accept_friend_request_usecase.dart';
import '../domain/usecases/reject_friend_request_usecase.dart';
import '../domain/usecases/remove_friend_usecase.dart';

class FriendsDependencyInjection {
  static late FriendRemoteDataSource _dataSource;
  static late FriendRepositoryImpl _repository;

  static late GetFriendsUseCase _getFriendsUseCase;
  static late SendFriendRequestUseCase _sendFriendRequestUseCase;
  static late AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  static late RejectFriendRequestUseCase _rejectFriendRequestUseCase;
  static late RemoveFriendUseCase _removeFriendUseCase;

  static void init() {
    // Data layer
    _dataSource = FriendRemoteDataSource(firestore: FirebaseFirestore.instance);
    _repository = FriendRepositoryImpl(remoteDataSource: _dataSource);

    // Use cases
    _getFriendsUseCase = GetFriendsUseCase(_repository);
    _sendFriendRequestUseCase = SendFriendRequestUseCase(_repository);
    _acceptFriendRequestUseCase = AcceptFriendRequestUseCase(_repository);
    _rejectFriendRequestUseCase = RejectFriendRequestUseCase(_repository);
    _removeFriendUseCase = RemoveFriendUseCase(_repository);
  }

  // Getters
  static FriendRepositoryImpl get repository => _repository;
  static GetFriendsUseCase get getFriendsUseCase => _getFriendsUseCase;
  static SendFriendRequestUseCase get sendFriendRequestUseCase =>
      _sendFriendRequestUseCase;
  static AcceptFriendRequestUseCase get acceptFriendRequestUseCase =>
      _acceptFriendRequestUseCase;
  static RejectFriendRequestUseCase get rejectFriendRequestUseCase =>
      _rejectFriendRequestUseCase;
  static RemoveFriendUseCase get removeFriendUseCase => _removeFriendUseCase;
}
