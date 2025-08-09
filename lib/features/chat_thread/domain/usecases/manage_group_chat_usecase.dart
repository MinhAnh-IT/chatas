import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/chat_thread_repository.dart';

class ManageGroupChatUseCase {
  final ChatThreadRepository repository;

  ManageGroupChatUseCase(this.repository);

  /// Add member to group chat
  Future<void> addMember({
    required String chatThreadId,
    required String memberId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Check if current user is admin
    if (!chatThread.canUserManage(currentUserId)) {
      throw Exception('Chỉ admin mới có thể thêm thành viên');
    }

    // Check if member is already in group
    if (chatThread.members.contains(memberId)) {
      throw Exception('Người này đã là thành viên của nhóm');
    }

    // Add member
    final updatedMembers = List<String>.from(chatThread.members);
    updatedMembers.add(memberId);

    await repository.updateChatThreadMembers(chatThreadId, updatedMembers);
  }

  /// Remove member from group chat
  Future<void> removeMember({
    required String chatThreadId,
    required String memberId,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Check if current user is admin
    if (!chatThread.canUserManage(currentUserId)) {
      throw Exception('Chỉ admin mới có thể xóa thành viên');
    }

    // Cannot remove admin
    if (memberId == chatThread.groupAdminId) {
      throw Exception('Không thể xóa admin khỏi nhóm');
    }

    // Check if member is in group
    if (!chatThread.members.contains(memberId)) {
      throw Exception('Người này không phải thành viên của nhóm');
    }

    // Remove member
    final updatedMembers = List<String>.from(chatThread.members);
    updatedMembers.remove(memberId);

    // Need at least 2 members (including admin)
    if (updatedMembers.length < 2) {
      throw Exception('Nhóm chat cần ít nhất 2 thành viên');
    }

    await repository.updateChatThreadMembers(chatThreadId, updatedMembers);
  }

  /// Update group name
  Future<void> updateGroupName({
    required String chatThreadId,
    required String newName,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    if (newName.trim().isEmpty) {
      throw Exception('Tên nhóm không được để trống');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Check if current user is admin
    if (!chatThread.canUserManage(currentUserId)) {
      throw Exception('Chỉ admin mới có thể đổi tên nhóm');
    }

    await repository.updateChatThreadName(chatThreadId, newName.trim());
  }

  /// Update group avatar
  Future<void> updateGroupAvatar({
    required String chatThreadId,
    required String newAvatarUrl,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Check if current user is admin
    if (!chatThread.canUserManage(currentUserId)) {
      throw Exception('Chỉ admin mới có thể đổi ảnh đại diện nhóm');
    }

    await repository.updateChatThreadAvatar(chatThreadId, newAvatarUrl);
  }

  /// Update group description
  Future<void> updateGroupDescription({
    required String chatThreadId,
    required String newDescription,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Check if current user is admin
    if (!chatThread.canUserManage(currentUserId)) {
      throw Exception('Chỉ admin mới có thể đổi mô tả nhóm');
    }

    await repository.updateChatThreadDescription(
      chatThreadId,
      newDescription.trim(),
    );
  }

  /// Leave group (for non-admin users)
  Future<void> leaveGroup({required String chatThreadId}) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Get current chat thread
    final chatThread = await repository.getChatThreadById(chatThreadId);
    if (chatThread == null) {
      throw Exception('Không tìm thấy nhóm chat');
    }

    // Admin cannot leave, must transfer admin rights first
    if (chatThread.isUserAdmin(currentUserId)) {
      throw Exception(
        'Admin không thể rời nhóm. Vui lòng chuyển quyền admin trước.',
      );
    }

    // Use the new leaveGroup method
    await repository.leaveGroup(chatThreadId, currentUserId);
  }
}
