import 'package:hive/hive.dart';
part 'entity_day_of_week.g.dart';

@HiveType(typeId: 4)
class DayOfWeek {
  @HiveField(0)
  int day;
  DayOfWeek({required this.day});
  factory DayOfWeek.fromJson(Map<String, dynamic> json) {
    return DayOfWeek(
      day: json['day'],
    );
  }
}
