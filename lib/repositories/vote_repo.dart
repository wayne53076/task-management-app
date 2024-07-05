import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/vote.dart';

class VoteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Vote>> streamVote(String serverId) {
    return _db
        .collection('servers/$serverId/votes')
        .orderBy('endTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Vote.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<Vote> streamSingleVote(String serverId, String voteId) {
    final docRef = _db.doc('servers/$serverId/votes/$voteId');
    return docRef.snapshots().map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return Vote.fromMap(data, snapshot.id);
    } else {
      throw Exception('Vote not found');
    }
  });
  }

  Future<String> addVote(String serverId, Vote vote) async {
    Map<String, dynamic> voteMap = vote.toMap();
    // Remove 'id' because Firestore automatically generates a unique document
    // ID for each new document added to the collection.
    voteMap.remove('id');
    // Ensure 'createdDate' is set by the server to maintain consistency across different clients,
    // independent of local time settings.
    voteMap['createdDate'] = FieldValue.serverTimestamp();
    DocumentReference docRef = await _db
        .collection('servers/$serverId/votes')
        .add(voteMap); // write to local cache immediately
    return docRef.id;
  }

  Future<void> deleteVote(String serverId, String voteId) async {
    await _db
        .collection('servers/$serverId/votes')
        .doc(voteId)
        .delete(); // write to local cache immediately
  }

  Future<void> updateVoteData(String serverId, String voteId, List<VoteData> voteData) async {
    await _db
        .collection('servers/$serverId/votes')
        .doc(voteId)
        .update({'voteData': voteData.map((item) => item.toMap()).toList()});
  }

  Future<void> updateVoteEndDateById(String serverId, String voteId, DateTime date) async {
    await _db
        .collection('servers/$serverId/votes')
        .doc(voteId)
        .update({'endTime': date});
  }
}
