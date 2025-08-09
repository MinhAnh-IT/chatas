import 'package:firebase_auth/firebase_auth.dart';
import '../entities/chat_thread.dart';
import '../repositories/chat_thread_repository.dart';

class CreateGroupChatUseCase {
  final ChatThreadRepository repository;

  CreateGroupChatUseCase(this.repository);

  Future<String> call({
    required String groupName,
    required List<String> memberIds,
    String? groupDescription,
    String? groupAvatarUrl,
  }) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId.isEmpty) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Add current user to members if not already included
    final allMembers = Set<String>.from(memberIds);
    allMembers.add(currentUserId);

    // Validate minimum members for group chat
    if (allMembers.length < 2) {
      throw Exception('Nhóm chat cần ít nhất 2 thành viên');
    }

    final now = DateTime.now();

    // Generate chat thread ID
    final chatThreadId = 'group_${DateTime.now().millisecondsSinceEpoch}';

    final chatThread = ChatThread(
      id: chatThreadId,
      name: groupName,
      lastMessage: 'Nhóm đã được tạo',
      lastMessageTime: now,
      avatarUrl: groupAvatarUrl ?? '',
      members: allMembers.toList(),
      isGroup: true,
      unreadCounts: {}, // Initialize empty unread counts
      createdAt: now,
      updatedAt: now,
      groupAdminId: currentUserId, // Creator becomes admin
      groupDescription: groupDescription,
    );

    await repository.createChatThread(chatThread);
    return chatThreadId;
  }
}
