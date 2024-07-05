import 'package:cloud_firestore/cloud_firestore.dart';

class VoteData {
  String option;
  int votes;
  List<String> voters; // This is the list of voters

  VoteData(this.option, this.votes, this.voters);

  // Add fromMap and toMap methods if needed
  factory VoteData.fromMap(Map<String, dynamic> data) {
    return VoteData(
      data['option'],
      data['votes'],
      List<String>.from(data['voters']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'option': option,
      'votes': votes,
      'voters': voters,
    };
  }
}


class Vote {
  String? id;
  late final DateTime endTime;
  final String topic;
  final List<VoteData> voteData;

  Timestamp? _createdDate;
  Timestamp get createdDate => _createdDate ?? Timestamp.now();

  bool hasVoted(userId) => voteData.any((data) => data.voters.contains(userId));

  // Constructor for Views or ViewModels
  Vote({
    required this.endTime,
    required this.topic,
    required this.voteData,
  });

  // Constructor for Firestore
  Vote._({
    required this.id,
    required this.endTime,
    required this.topic,
    required this.voteData,
    required Timestamp? createdDate,
  }) : _createdDate = createdDate;

  factory Vote.fromMap(Map<String, dynamic> map, String id) {
    return Vote._(
      id: id,
      endTime: map['endTime'].toDate(),
      topic: map['topic'],
      voteData: (map['voteData'] as List<dynamic>)
          .map((item) => VoteData.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdDate: map['createdDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'endTime': endTime,
      'topic': topic,
      'voteData': voteData.map((item) => item.toMap()).toList(),
      'createdDate': _createdDate,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
