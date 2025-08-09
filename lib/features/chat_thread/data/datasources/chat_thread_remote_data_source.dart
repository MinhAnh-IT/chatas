import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_thread_model.dart';
import '../../constants/chat_thread_remote_constants.dart';
import '../../domain/entities/chat_thread.dart';

class ChatThreadRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatThreadRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ChatThreadModel>> fetchChatThreads(String currentUserId) async {
    print(
      'ChatThreadRemoteDataSource: Fetching threads for user: $currentUserId',
    );
    final snapshot = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .where(
          'members',
          arrayContains: currentUserId,
        ) // Only threads where user is a member
        .get();
    print(
      'ChatThreadRemoteDataSource: Found ${snapshot.docs.length} threads for user $currentUserId',
    );

    // Debug: Print details of each thread
    final threads = snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Set document ID from Firestore
          print(
            'ChatThreadRemoteDataSource: Thread ${doc.id} - Members: ${data['members']}, Name: ${data['name']}, AvatarUrl: ${data['avatarUrl']}, HiddenFor: ${data['hiddenFor'] ?? []}',
          );
          return ChatThreadModel.fromJson(data);
        })
        .where((thread) => !thread.hiddenFor.contains(currentUserId))
        .toList(); // Filter out hidden threads

    // Sort by lastMessageTime in descending order (newest first)
    threads.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1; // Null goes to end
      if (b.lastMessageTime == null) return -1; // Null goes to end
      return b.lastMessageTime!.compareTo(a.lastMessageTime!); // Newest first
    });

    print(
      'ChatThreadRemoteDataSource: After filtering hidden threads: ${threads.length} threads visible for user $currentUserId',
    );

    return threads;
  }

  Future<List<ChatThreadModel>> fetchAllChatThreads(
    String currentUserId,
  ) async {
    print(
      'ChatThreadRemoteDataSource: Fetching ALL threads (including hidden) for user: $currentUserId',
    );
    final snapshot = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .where(
          'members',
          arrayContains: currentUserId,
        ) // Only threads where user is a member
        .get();
    print(
      'ChatThreadRemoteDataSource: Found ${snapshot.docs.length} total threads for user $currentUserId',
    );

    // Return all threads without filtering hidden ones
    final threads = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Set document ID from Firestore
      print(
        'ChatThreadRemoteDataSource: ALL Thread ${doc.id} - Members: ${data['members']}, Name: ${data['name']}, HiddenFor: ${data['hiddenFor'] ?? []}',
      );
      return ChatThreadModel.fromJson(data);
    }).toList();

    // Sort by lastMessageTime in descending order (newest first)
    threads.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1; // Null goes to end
      if (b.lastMessageTime == null) return -1; // Null goes to end
      return b.lastMessageTime!.compareTo(a.lastMessageTime!); // Newest first
    });

    print(
      'ChatThreadRemoteDataSource: Returning ${threads.length} total threads for user $currentUserId',
    );

    return threads;
  }

  /// Gets archived (hidden) chat threads for a specific user
  Future<List<ChatThreadModel>> getArchivedChatThreads(
    String currentUserId,
  ) async {
    print(
      '🔍 ChatThreadRemoteDataSource: FETCHING ARCHIVED THREADS for user: $currentUserId',
    );

    final snapshot = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .where('members', arrayContains: currentUserId)
        // .orderBy('updatedAt', descending: true) // Temporarily removed due to missing index
        .get();

    print(
      '🔍 ChatThreadRemoteDataSource: Found ${snapshot.docs.length} total threads for user $currentUserId',
    );

    // Get all threads and filter only the hidden ones
    final allThreads = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      final model = ChatThreadModel.fromJson(data);

      print(
        '🔍 Thread ${doc.id}: name="${model.name}", hiddenFor=${model.hiddenFor}, isHidden=${model.hiddenFor.contains(currentUserId)}',
      );

      return model;
    }).toList();

    // Filter only threads that are hidden for this user
    final archivedThreads = allThreads
        .where((thread) => thread.hiddenFor.contains(currentUserId))
        .toList();

    // Sort by updatedAt since we removed orderBy from query
    archivedThreads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    print(
      '🎯 ChatThreadRemoteDataSource: RESULT = ${archivedThreads.length} archived threads for user $currentUserId',
    );

    for (final thread in archivedThreads) {
      print(
        '✅ ARCHIVED: ${thread.id} - Name: "${thread.name}", HiddenFor: ${thread.hiddenFor}',
      );
    }

    if (archivedThreads.isEmpty) {
      print('❌ NO ARCHIVED THREADS FOUND! All threads hiddenFor status:');
      for (final thread in allThreads) {
        print(
          '   - ${thread.name}: hiddenFor=${thread.hiddenFor}, contains($currentUserId)=${thread.hiddenFor.contains(currentUserId)}',
        );
      }
    }

    return archivedThreads;
  }

  Future<void> addChatThread(ChatThreadModel model) async {
    print(
      'ChatThreadRemoteDataSource: Adding chat thread with ID: ${model.id}',
    );
    final data = model.toJson();
    data.remove('id'); // Remove ID from data as it will be the document ID
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(model.id) // Use our specified ID as document ID
        .set(data);
    print('ChatThreadRemoteDataSource: Chat thread added successfully');
  }

  Future<void> updateChatThread(String id, ChatThreadModel model) async {
    final data = model.toJson();
    data.remove('id'); // Remove ID from data as it's the document ID
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(id)
        .update(data);
  }

  Future<void> updateChatThreadMembers(
    String threadId,
    List<String> members,
  ) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'members': members,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> updateChatThreadName(String threadId, String name) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({'name': name, 'updatedAt': DateTime.now().toIso8601String()});
  }

  Future<void> updateChatThreadAvatar(String threadId, String avatarUrl) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'avatarUrl': avatarUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> updateLastMessage(
    String threadId,
    String message,
    DateTime timestamp,
  ) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'lastMessage': message,
          'lastMessageTime': timestamp.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> incrementUnreadCount(String threadId, String userId) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'unreadCounts.$userId': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> resetUnreadCount(String threadId, String userId) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'unreadCounts.$userId': 0,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<ChatThreadModel?> getChatThreadById(String threadId) async {
    final doc = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return ChatThreadModel.fromJson(data);
  }

  Future<void> deleteChatThread(String id) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(id)
        .delete();
  }

  Future<void> hideChatThread(String threadId, String userId) async {
    print(
      'ChatThreadRemoteDataSource: Hiding chat thread $threadId for user $userId',
    );

    // Get current thread data
    final threadDoc = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .get();

    if (!threadDoc.exists) {
      throw Exception('Chat thread not found');
    }

    final data = threadDoc.data()!;
    final currentHiddenFor = List<String>.from(data['hiddenFor'] ?? []);

    // Add user to hiddenFor list if not already there
    if (!currentHiddenFor.contains(userId)) {
      currentHiddenFor.add(userId);
    }

    // Update the thread with new hiddenFor list
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'hiddenFor': currentHiddenFor,
          'updatedAt': DateTime.now().toIso8601String(),
        });

    print(
      'ChatThreadRemoteDataSource: Successfully hidden thread $threadId for user $userId',
    );
  }

  Future<void> unhideChatThread(String threadId, String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final threadRef = firestore
          .collection(ChatThreadRemoteConstants.collectionName)
          .doc(threadId);

      // Get current thread data
      final threadDoc = await threadRef.get();
      if (!threadDoc.exists) {
        throw Exception('Chat thread not found');
      }

      final threadData = threadDoc.data()!;
      final currentHiddenFor = List<String>.from(threadData['hiddenFor'] ?? []);

      // Remove user from hiddenFor list
      currentHiddenFor.remove(userId);

      // Update the thread
      await threadRef.update({
        'hiddenFor': currentHiddenFor,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'ChatThreadRemoteDataSource: Unhidden thread $threadId for user $userId',
      );
    } catch (e) {
      print('ChatThreadRemoteDataSource: Error unhiding thread: $e');
      rethrow;
    }
  }

  Future<void> updateLastRecreatedAt(
    String threadId,
    DateTime timestamp,
  ) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'lastRecreatedAt': timestamp.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> markThreadDeletedForUser(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'hiddenFor': FieldValue.arrayUnion([userId]),
          'visibilityCutoff.$userId': cutoff.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> archiveThreadForUser(String threadId, String userId) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'hiddenFor': FieldValue.arrayUnion([userId]),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> reviveThreadForUser(String threadId, String userId) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'hiddenFor': FieldValue.arrayRemove([userId]),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> leaveGroup(String threadId, String userId) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'members': FieldValue.arrayRemove([userId]),
          'joinedAt.$userId': FieldValue.delete(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> joinGroup(String threadId, String userId) async {
    final now = DateTime.now();
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'members': FieldValue.arrayUnion([userId]),
          'joinedAt.$userId': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });
  }

  Future<ChatThread> findOrCreate1v1Thread(
    String user1,
    String user2,
    String? threadName,
    String? avatarUrl,
  ) async {
    // Generate consistent thread ID for 1-1 chats
    final threadId = ChatThread.generate1v1ThreadId(user1, user2);

    // Try to find existing thread
    final existingThread = await getChatThreadById(threadId);
    if (existingThread != null) {
      return existingThread.toEntity();
    }

    // Create new thread if not found
    final now = DateTime.now();
    final newThread = ChatThread(
      id: threadId,
      name: threadName ?? 'Chat',
      lastMessage: '',
      lastMessageTime: now,
      avatarUrl: avatarUrl ?? '',
      members: [user1, user2]..sort(),
      isGroup: false,
      unreadCounts: {},
      createdAt: now,
      updatedAt: now,
      visibilityCutoff: {},
    );

    final model = ChatThreadModel.fromEntity(newThread);
    await addChatThread(model);
    return newThread;
  }

  Future<void> resetThreadForUser(String threadId, String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final threadRef = firestore
          .collection(ChatThreadRemoteConstants.collectionName)
          .doc(threadId);

      // Get current thread data
      final threadDoc = await threadRef.get();
      if (!threadDoc.exists) {
        throw Exception('Chat thread not found');
      }

      final threadData = threadDoc.data()!;
      final currentUnreadCounts = Map<String, int>.from(
        threadData['unreadCounts'] ?? {},
      );

      // Remove unread count for this user
      currentUnreadCounts.remove(userId);

      // Update the thread - only reset unread count for this user
      // Don't reset lastMessage as it affects other users
      await threadRef.update({
        'unreadCounts': currentUnreadCounts,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
        'ChatThreadRemoteDataSource: Reset thread $threadId for user $userId',
      );
    } catch (e) {
      print('ChatThreadRemoteDataSource: Error resetting thread for user: $e');
      rethrow;
    }
  }

  Future<List<ChatThreadModel>> searchChatThreads(
    String query,
    String currentUserId,
  ) async {
    try {
      final threads = await fetchChatThreads(currentUserId);

      final lowercaseQuery = query.toLowerCase().trim();
      final filteredThreads = <ChatThreadModel>[];

      for (final thread in threads) {
        final threadName = thread.name.toLowerCase();
        final lastMessage = thread.lastMessage.toLowerCase();

        if (threadName.contains(lowercaseQuery) ||
            lastMessage.contains(lowercaseQuery)) {
          filteredThreads.add(thread);
        }
      }

      return filteredThreads;
    } catch (e) {
      print('ChatThreadRemoteDataSource: Error searching chat threads: $e');
      rethrow;
    }
  }

  Stream<List<ChatThreadModel>> chatThreadsStream(String currentUserId) {
    print(
      'ChatThreadRemoteDataSource: Setting up threads stream for user: $currentUserId',
    );
    return firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .where(
          'members',
          arrayContains: currentUserId,
        ) // Only threads where user is a member
        .snapshots()
        .map((snapshot) {
          print(
            'ChatThreadRemoteDataSource: Stream received ${snapshot.docs.length} threads for user',
          );
          return snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id; // Set document ID from Firestore
                return ChatThreadModel.fromJson(data);
              })
              .where((thread) => !thread.hiddenFor.contains(currentUserId))
              .toList(); // Filter out hidden threads
        });
  }

  // New methods for group chat management
  Future<void> createChatThread(ChatThreadModel model) async {
    print(
      'ChatThreadRemoteDataSource: Creating chat thread with ID: ${model.id}',
    );
    final data = model.toJson();
    data.remove('id'); // Remove ID from data as it will be the document ID
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(model.id) // Use our specified ID as document ID
        .set(data);
    print('ChatThreadRemoteDataSource: Chat thread created successfully');
  }

  Future<void> updateChatThreadDescription(
    String chatThreadId,
    String description,
  ) async {
    print(
      'ChatThreadRemoteDataSource: Updating description for chat thread: $chatThreadId',
    );
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(chatThreadId)
        .update({
          'groupDescription': description,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> updateVisibilityCutoff(
    String threadId,
    String userId,
    DateTime cutoff,
  ) async {
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'visibilityCutoff.$userId': cutoff.toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }
}
