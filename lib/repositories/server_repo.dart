import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/server.dart';

class ServerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Server?> streamServer(String serverId) {
    return _db
        .collection('servers')
        .doc(serverId)
        .snapshots()
        .map((snapshot) {
      return snapshot.data() == null
          ? null
          : Server.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> createOrUpdateServer(Server server) async {
    Map<String, dynamic> serverMap = server.toMap();
    await _db
        .collection('servers')
        .doc(server.id)
        .set(serverMap); // write to local cache immediately
  }

}
