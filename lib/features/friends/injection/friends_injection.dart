import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/datasources/friendDataSource.dart';
import '../data/repositories/friend_repository_impl.dart';
import '../domain/usecases/get_friends_usecase.dart';
import '../domain/usecases/block_friend_usecase.dart';
import '../presentation/cubit/friends_list_cubit.dart';

class FriendsDependencyInjection {
  static late FriendRemoteDataSource _dataSource;
  static late FriendRepositoryImpl _repository;

  static late GetFriendsUseCase _getFriendsUseCase;
  static late BlockFriendUseCase _blockFriendUseCase;

  static void init() {
    // Data layer
    _dataSource = FriendRemoteDataSource(firestore: FirebaseFirestore.instance);
    _repository = FriendRepositoryImpl(remoteDataSource: _dataSource);

    // Use cases
    _getFriendsUseCase = GetFriendsUseCase(_repository);
    _blockFriendUseCase = BlockFriendUseCase(_repository);
  }

  // Getters
  static FriendRepositoryImpl get repository => _repository;
  static GetFriendsUseCase get getFriendsUseCase => _getFriendsUseCase;
  static BlockFriendUseCase get blockFriendUseCase => _blockFriendUseCase;

  // Cubit factory
  static FriendsListCubit createFriendsListCubit() {
    return FriendsListCubit(
      getFriendsUseCase: _getFriendsUseCase,
      blockFriendUseCase: _blockFriendUseCase,
    );
  }
}
