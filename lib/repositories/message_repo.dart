import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/message.dart';

class MessageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Message>> streamMessages(String serverId) {
    return _db
        .collection('servers/$serverId/messages')
        .orderBy('createdDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String> addMessage(String serverId, Message message) async {
    Map<String, dynamic> messageMap = message.toMap();
    // Remove 'id' because Firestore automatically generates a unique document 
    // ID for each new document added to the collection.
    messageMap.remove('id');
    // Ensure 'createdDate' is set by the server to maintain consistency across different clients, 
    // independent of local time settings.
    messageMap['createdDate'] = FieldValue.serverTimestamp();
    DocumentReference docRef = await _db
        .collection('servers/$serverId/messages')
        .add(messageMap); // write to local cache immediately
    return docRef.id;
  }

  Future<void> deleteMessage(String serverId, String messageId) async {
    await _db
        .collection('servers/$serverId/messages')
        .doc(messageId)
        .delete(); // write to local cache immediately
  }
}
