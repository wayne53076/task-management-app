import 'package:task_management_app/models/log_in_method.dart';

class User {
  String id; // use the ID from authentication service
  final String email;
  final String name;
  final String avatarUrl;

  List<List<bool>> hasAvailableTime;

  final List<String> joinedServer; // all of the servers user joined
  late final List<LogInMethod> logInMethods;
  String? pushMessagingToken;
  String currentServerId; // update when changing server

  // Read-only fields that can only be set by the system
  bool _isModerator = false;
  bool get isModerator => _isModerator;


  User({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.hasAvailableTime,
    required this.joinedServer,
    logInMethods,
    this.pushMessagingToken,
    currentServerId,
  }) : logInMethods = logInMethods ?? [],
   currentServerId = currentServerId ?? '0';


  User._({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.hasAvailableTime,
    required this.joinedServer,
    logInMethods,
    this.pushMessagingToken,
    currentServerId,  
    isModerator = false,
  })  : logInMethods = logInMethods ?? [],
  currentServerId = currentServerId ?? '0',
        _isModerator = isModerator;

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User._(
      id: id,
      email: map['email'],
      name: map['name'],
      avatarUrl: map['avatarUrl'],
      hasAvailableTime: _restoreAvailableData(map['hasAvailableTime']),
      joinedServer: (map['joinedServer'] as List<dynamic>)
          .map((joinedServer) => joinedServer.toString())
          .toList(),
      logInMethods: (map['logInMethods'] as List<dynamic>)
          .map((logInMethod) => LogInMethod.values.byName(logInMethod))
          .toList(),
      pushMessagingToken: map['pushMessagingToken'],
      currentServerId: map['currentServerId'],
      isModerator: map['isModerator'],
    );
  }

  static List<List<bool>> _restoreAvailableData(dynamic data) {
    List<bool> flattenedList = List<bool>.from(data as List<dynamic>);
    List<List<bool>> restoredData = [];

    for (int i = 0; i < flattenedList.length; i += 7) {
      restoredData.add(flattenedList.sublist(i, i + 7));// each row has 7 entries for 7 days
    }

    return restoredData;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'hasAvailableTime': hasAvailableTime.expand((row) => row).toList(),
      'joinedServer': joinedServer,
      'logInMethods':
          logInMethods.map((logInMethod) => logInMethod.name).toList(),
      'pushMessagingToken': pushMessagingToken,
      'currentServerId':currentServerId,
      'isModerator': _isModerator,
    };
  }
}
