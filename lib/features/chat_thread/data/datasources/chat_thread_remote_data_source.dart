import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_thread_model.dart';
import '../../constants/chat_thread_remote_constants.dart';

class ChatThreadRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatThreadRemoteDataSource({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ChatThreadModel>> fetchChatThreads() async {
    final snapshot = await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Set document ID from Firestore
      return ChatThreadModel.fromJson(data);
    }).toList();
  }

  Future<void> addChatThread(ChatThreadModel model) async {
    final data = model.toJson();
    data.remove('id'); // Remove ID from data as Firestore will auto-generate
    await firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .add(data);
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

  Stream<List<ChatThreadModel>> chatThreadsStream() {
    return firestore
        .collection(ChatThreadRemoteConstants.collectionName)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Set document ID from Firestore
            return ChatThreadModel.fromJson(data);
          }).toList();
        });
  }
}
