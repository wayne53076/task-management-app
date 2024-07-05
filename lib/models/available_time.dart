class AvailableTime {
  final List<List<int>> availableData;
  static int days = 7; // col
  static int hours = 24; // row

  AvailableTime({
    required this.availableData,
  });

  factory AvailableTime.fromMap(Map<String, dynamic> map) {
    List<int> flattenedList = List<int>.from(map['availableData'] as List<dynamic>);

    if (flattenedList.length != days * hours) {
      throw Exception('Invalid data length: ${flattenedList.length}');
    }

    List<List<int>> restoredData = [];

    for (int i = 0; i < flattenedList.length; i += days) {
      restoredData.add(flattenedList.sublist(i, i + days));
    }

    if (restoredData.length !=  hours) {
      throw Exception('Invalid data length: ${restoredData.length}');
    }

    return AvailableTime(
      availableData: restoredData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'availableData': availableData.expand((row) => row).toList(),
    };
  }

  static AvailableTime createEmpty() {
    return AvailableTime(
      availableData: List.generate(days, (_) => List.filled(hours, 0)),
    );
  }
}
