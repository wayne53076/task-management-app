import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_management_app/models/todo.dart';

class TodoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Todo>> streamTodo(String serverId) {
    return _db
        .collection('servers/$serverId/todos')
        .orderBy('endTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<String> addTodo(String serverId, Todo todo) async {
    Map<String, dynamic> todoMap = todo.toMap();
    // Remove 'id' because Firestore automatically generates a unique document 
    // ID for each new document added to the collection.
    todoMap.remove('id');
    // Ensure 'createdDate' is set by the server to maintain consistency across different clients, 
    // independent of local time settings.
    todoMap['createdDate'] = FieldValue.serverTimestamp();
    DocumentReference docRef = await _db
        .collection('servers/$serverId/todos')
        .add(todoMap); // write to local cache immediately
    return docRef.id;
  }

  Future<void> deleteTodo(String serverId,String todoId) async {
    await _db
        .collection('servers/$serverId/todos')
        .doc(todoId)
        .delete(); // write to local cache immediately
  }

  Future<void> updateTodo(String serverId,String todoId, Todo todo) async {
    Map<String, dynamic> todoMap = todo.toMap();
    // Remove 'id' since it's not needed for the update.
    todoMap.remove('id');
    await _db
        .collection('servers/$serverId/todos')
        .doc(todoId)
        .update(todoMap); // write to local cache immediately
  }
}
