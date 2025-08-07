import '../repositories/friend_repository.dart';

class SearchUsersUseCase {
  final FriendRepository repository;

  SearchUsersUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call(
    String query,
    String currentUserId,
  ) async {
    if (query.isEmpty) {
      return [];
    }
    return await repository.searchUsers(query, currentUserId);
  }
}
