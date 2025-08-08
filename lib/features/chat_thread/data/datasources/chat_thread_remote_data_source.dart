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
    final threads = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Set document ID from Firestore
      print(
        'ChatThreadRemoteDataSource: Thread ${doc.id} - Members: ${data['members']}, Name: ${data['name']}',
      );
      return ChatThreadModel.fromJson(data);
    }).toList();

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
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Set document ID from Firestore
            return ChatThreadModel.fromJson(data);
          }).toList();
        });
  }
}
