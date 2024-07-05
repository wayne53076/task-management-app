import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp


class Todo {
  String? id;
  final DateTime startTime;
  final DateTime endTime;
  final String taskName;
  final String importance;
  final String assignee;
  final String description;
  bool isDone;

  Timestamp? _createdDate;
  Timestamp get createdDate =>
      _createdDate ??
      Timestamp
          .now(); 
  // Unlike 'id', the '_createdDate' is only assigned a value at the time
  // the data is written to the Firestore database on the server.
  // Before this synchronization, '_createdDate' will be null in the local cache.
  // Here, we provide a fallback value for the UI to render it properly.

  // Constructor for Views or ViewModels
  Todo({
    required this.taskName,
    required this.startTime,
    required this.endTime,
    required this.importance,
    required this.assignee,
    required this.description,
    required this.isDone,
  });

  // Constructor for firestore
  Todo._({
    required this.id,
    required this.taskName,
    required this.startTime,
    required this.endTime,
    required this.importance,
    required this.assignee,
    required this.description,
    required this.isDone,
    required Timestamp? createdDate,
  }) : _createdDate = createdDate;

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    return Todo._(
      id: id,
      taskName: map['taskName'],
      startTime: map['startTime'].toDate(),
      endTime: map['endTime'].toDate(),
      importance: map['importance'],
      assignee: map['assignee'],
      description: map['description'],
      isDone: map['isDone'],
      createdDate: map['createdDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskName': taskName,
      'startTime': startTime,
      'endTime': endTime,
      'importance': importance,
      'assignee': assignee,
      'description': description,
      'isDone': isDone,
      'createdDate': _createdDate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
