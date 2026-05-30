import '../models/create_event_models.dart';
import '../models/stored_calendar_event.dart';

abstract final class CalendarEventExpander {
  CalendarEventExpander._();

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool occursOnDay(StoredCalendarEvent event, DateTime day) {
    final target = dateOnly(day);

    if (!event.isRecurring) {
      final start = dateOnly(event.startDate);
      final end = dateOnly(event.endDate);
      return !target.isBefore(start) && !target.isAfter(end);
    }

    final recurrence = event.recurrence;
    if (recurrence == null) return false;

    final until = dateOnly(recurrence.until);
    if (target.isAfter(until)) return false;

    switch (recurrence.frequency) {
      case EventRecurrenceFrequency.weekly:
        return _occursWeekly(event, recurrence, target);
      case EventRecurrenceFrequency.monthly:
        return _occursMonthly(event, recurrence, target);
      case EventRecurrenceFrequency.yearly:
        return _occursYearly(event, recurrence, target);
      default:
        return false;
    }
  }

  static bool _occursWeekly(
    StoredCalendarEvent event,
    StoredEventRecurrence recurrence,
    DateTime target,
  ) {
    final seriesStart = dateOnly(recurrence.startDate);
    if (target.isBefore(seriesStart)) return false;
    if (recurrence.daysOfWeek.isEmpty) return false;
    final weekdayIndex = target.weekday % 7;
    return recurrence.daysOfWeek.contains(weekdayIndex);
  }

  static bool _occursMonthly(
    StoredCalendarEvent event,
    StoredEventRecurrence recurrence,
    DateTime target,
  ) {
    final seriesStart = dateOnly(recurrence.startDate);
    if (target.isBefore(seriesStart)) return false;

    final startDay = event.startDate.day;
    final endDay = event.endDate.day;
    return target.day >= startDay && target.day <= endDay;
  }

  static bool _occursYearly(
    StoredCalendarEvent event,
    StoredEventRecurrence recurrence,
    DateTime target,
  ) {
    final seriesStart = dateOnly(recurrence.startDate);
    if (target.isBefore(seriesStart)) return false;

    final startOrdinal = _yearDayOrdinal(event.startDate.month, event.startDate.day);
    final endOrdinal = _yearDayOrdinal(event.endDate.month, event.endDate.day);
    final targetOrdinal = _yearDayOrdinal(target.month, target.day);
    return targetOrdinal >= startOrdinal && targetOrdinal <= endOrdinal;
  }

  static int _yearDayOrdinal(int month, int day) => month * 100 + day;

  static Set<DateTime> datesWithEvents(
    List<StoredCalendarEvent> events,
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final result = <DateTime>{};
    var cursor = dateOnly(rangeStart);
    final end = dateOnly(rangeEnd);

    while (!cursor.isAfter(end)) {
      for (final event in events) {
        if (occursOnDay(event, cursor)) {
          result.add(cursor);
          break;
        }
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return result;
  }

  static List<CalendarEventOccurrence> occurrencesForDay(
    List<StoredCalendarEvent> events,
    DateTime day,
  ) {
    final target = dateOnly(day);
    final result = <CalendarEventOccurrence>[];

    for (final event in events) {
      if (!occursOnDay(event, target)) continue;
      result.add(
        CalendarEventOccurrence(
          event: event,
          day: target,
          displayStart: _displayStart(event, target),
          displayEnd: _displayEnd(event, target),
        ),
      );
    }

    result.sort(
      (a, b) => a.displayStart.compareTo(b.displayStart),
    );
    return result;
  }

  static DateTime _displayStart(StoredCalendarEvent event, DateTime day) {
    if (event.isAllDayEvent) return day;
    if (!event.isRecurring) return event.startDate;
    return DateTime(
      day.year,
      day.month,
      day.day,
      event.startDate.hour,
      event.startDate.minute,
    );
  }

  static DateTime _displayEnd(StoredCalendarEvent event, DateTime day) {
    if (event.isAllDayEvent) return day;
    if (!event.isRecurring) return event.endDate;
    return DateTime(
      day.year,
      day.month,
      day.day,
      event.endDate.hour,
      event.endDate.minute,
    );
  }
}
