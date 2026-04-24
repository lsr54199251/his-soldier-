import 'package:uuid/uuid.dart';

class GraceRoutine {
  final String id;
  final String type; // 'morning' or 'evening'
  final String timestamp; // ISO-8601 string
  final String? note;
  final String? gratitude;
  final String? concern;
  final String? reflection;

  GraceRoutine({
    required this.id,
    required this.type,
    required this.timestamp,
    this.note,
    this.gratitude,
    this.concern,
    this.reflection,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp,
      'note': note,
      'gratitude': gratitude,
      'concern': concern,
      'reflection': reflection,
    };
  }

  factory GraceRoutine.fromJson(Map<String, dynamic> json) {
    return GraceRoutine(
      id: json['id'] as String? ?? const Uuid().v4(),
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
      note: json['note'] as String?,
      gratitude: json['gratitude'] as String?,
      concern: json['concern'] as String?,
      reflection: json['reflection'] as String?,
    );
  }
}

class GraceTodayStatus {
  final String date;
  final bool morningDone;
  final bool eveningDone;

  GraceTodayStatus({
    required this.date,
    this.morningDone = false,
    this.eveningDone = false,
  });

  GraceTodayStatus copyWith({
    String? date,
    bool? morningDone,
    bool? eveningDone,
  }) {
    return GraceTodayStatus(
      date: date ?? this.date,
      morningDone: morningDone ?? this.morningDone,
      eveningDone: eveningDone ?? this.eveningDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'morningDone': morningDone,
      'eveningDone': eveningDone,
    };
  }

  factory GraceTodayStatus.fromJson(Map<String, dynamic> json) {
    return GraceTodayStatus(
      date: json['date'] as String,
      morningDone: json['morningDone'] as bool? ?? false,
      eveningDone: json['eveningDone'] as bool? ?? false,
    );
  }
}
