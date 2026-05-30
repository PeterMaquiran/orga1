import 'package:hive/hive.dart';
import 'entity_day_of_week.dart';

part 'entity_event_recurrence.g.dart';

@HiveType(typeId: 3)
class EventRecurrence {
  @HiveField(0)
  DateTime startDate;
  @HiveField(1)
  int frequency;
  @HiveField(2)
  int occurrences;

  @HiveField(3)
  DateTime until;

  @HiveField(4)
  DateTime? last;

  @HiveField(5)
  List<DayOfWeek>? daysOfWeek;
  EventRecurrence(
      {required this.startDate,
      required this.frequency,
      required this.occurrences,
      required this.until,
      this.last,
      this.daysOfWeek});

  factory EventRecurrence.fromJson(Map<String, dynamic> json) {
    return EventRecurrence(
      last: DateTime.parse(json["last"]).toLocal(),
      startDate: DateTime.parse(json['startDate']).toLocal(),
      frequency: json['frequency'],
      occurrences: json['occurrences'],
      until: DateTime.parse(json['until']).toLocal(),
      daysOfWeek: (json['daysOfWeek'] as List)
          .map((day) => DayOfWeek.fromJson(day))
          .toList(),
    );
  }
}
