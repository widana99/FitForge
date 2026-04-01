class ScheduleModel {
  final String id;
  final int dayOfWeek; // 1=Monday, 7=Sunday
  final String time; // "07:00"
  final bool isActive;

  ScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.time,
    this.isActive = true,
  });

  String get dayName {
    const days = [
      '',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[dayOfWeek];
  }

  String get dayShort {
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[dayOfWeek];
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleModel(
      id: id,
      dayOfWeek: map['dayOfWeek'] ?? 1,
      time: map['time'] ?? '07:00',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'dayOfWeek': dayOfWeek, 'time': time, 'isActive': isActive};
  }
}

class WeightLogModel {
  final String id;
  final double weight;
  final DateTime date;

  WeightLogModel({required this.id, required this.weight, required this.date});

  factory WeightLogModel.fromMap(Map<String, dynamic> map, String id) {
    return WeightLogModel(
      id: id,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['date'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'weight': weight, 'date': date};
  }
}
