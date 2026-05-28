import 'package:hive/hive.dart';

part 'habit_event.g.dart';

@HiveType(typeId: 1) // Unique typeId for the events collection
class HabitEvent extends HiveObject {

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId; // Links this event transaction back to its parent Habit

  @HiveField(2)
  final DateTime timestamp; // Exact date and time the progress occurred

  @HiveField(3)
  final double valueLogged; // e.g., 0.5 for liters, 1.0 for checkmarks

  @HiveField(4)
  final String? note; // Optional text contextual note

  HabitEvent({
    required this.id,
    required this.habitId,
    required this.timestamp,
    required this.valueLogged,
    this.note,
  });

  // --- BACKEND MAP INTEGRATION (For future REST/GraphQL sync) ---
  factory HabitEvent.fromMap(Map<String, dynamic> map) {
    return HabitEvent(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      valueLogged: (map['valueLogged'] as num).toDouble(),
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'timestamp': timestamp.toIso8601String(), // ISO format matches database conventions
      'valueLogged': valueLogged,
      'note': note,
    };
  }
}