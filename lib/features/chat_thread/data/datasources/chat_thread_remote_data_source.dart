import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_thread_model.dart';
import '../../constants/chat_thread_remote_constants.dart';

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

    print(
      'ChatThreadRemoteDataSource: Returning ${threads.length} total threads for user $currentUserId',
    );

    return threads;
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
    print(
      'ChatThreadRemoteDataSource: Unhiding chat thread $threadId for user $userId',
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

    // Remove user from hiddenFor list
    currentHiddenFor.remove(userId);

    // Update the thread with new hiddenFor list
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(threadId)
        .update({
          'hiddenFor': currentHiddenFor,
          'updatedAt': DateTime.now().toIso8601String(),
        });

    print(
      'ChatThreadRemoteDataSource: Successfully unhidden thread $threadId for user $userId',
    );
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

  Future<ChatThreadModel?> getChatThreadById(String chatThreadId) async {
    print(
      'ChatThreadRemoteDataSource: Getting chat thread by ID: $chatThreadId',
    );
    final doc = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(chatThreadId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id; // Set document ID from Firestore
      return ChatThreadModel.fromJson(data);
    }
    return null;
  }

  Future<void> updateChatThreadMembers(
    String chatThreadId,
    List<String> members,
  ) async {
    print(
      'ChatThreadRemoteDataSource: Updating members for chat thread: $chatThreadId',
    );
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(chatThreadId)
        .update({
          'members': members,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> updateChatThreadName(String chatThreadId, String name) async {
    print(
      'ChatThreadRemoteDataSource: Updating name for chat thread: $chatThreadId',
    );
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(chatThreadId)
        .update({'name': name, 'updatedAt': DateTime.now().toIso8601String()});
  }

  Future<void> updateChatThreadAvatar(
    String chatThreadId,
    String avatarUrl,
  ) async {
    print(
      'ChatThreadRemoteDataSource: Updating avatar for chat thread: $chatThreadId',
    );
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .doc(chatThreadId)
        .update({
          'avatarUrl': avatarUrl,
          'updatedAt': DateTime.now().toIso8601String(),
        });
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
}
