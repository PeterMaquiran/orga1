import 'stored_calendar_event.dart';

class CalendarDayEventGroup {
  const CalendarDayEventGroup({
    required this.day,
    required this.occurrences,
  });

  final DateTime day;
  final List<CalendarEventOccurrence> occurrences;
}
