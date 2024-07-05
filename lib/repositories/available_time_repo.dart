import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/available_time.dart';

class AvailableTimeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<AvailableTime> streamAvailableTime(String serverId) {
    return _db
        .collection('servers/$serverId/availableTime')
        .doc('0')
        .snapshots()
        .asyncMap((doc) async {
      if (doc.exists) {
        return AvailableTime.fromMap(doc.data()!);
      } else {
        AvailableTime emptyAvailableTime = AvailableTime.createEmpty();
        await _db
            .collection('servers/$serverId/availableTime')
            .doc('0')
            .set(emptyAvailableTime.toMap());
        return emptyAvailableTime;
      }
    });
  }

  Future<void> updateAvailableTime(String serverId,AvailableTime availableTime) async {
    try {
      Map<String, dynamic> availableTimeMap = availableTime.toMap();
      await _db
          .collection('servers/$serverId/availableTime')
          .doc('0')
          .set(availableTimeMap, SetOptions(merge: true));
    } catch (e) {
      print('Error updating available time: $e');
    }
  }
}
