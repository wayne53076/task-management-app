
class Server {
  String id; // Server ID
  final String name; // Server name

  Server({
    required this.id,
    required this.name,
  });

  factory Server.fromMap(Map<String, dynamic> map, String id) {
    return Server(
      id: id,
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'id': id,
      'name': name,
    };
  }
}
