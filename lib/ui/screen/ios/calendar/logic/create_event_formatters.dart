import '../models/create_event_models.dart';
import '../models/stored_calendar_event.dart';

abstract final class CreateEventFormatters {
  CreateEventFormatters._();

  static const monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String pad(int value) => value.toString().padLeft(2, '0');

  static String formatDateOnly(DateTime time) =>
      '${monthsShort[time.month - 1]} ${time.day}, ${time.year}';

  static String formatShortDate(DateTime time) =>
      '${monthsShort[time.month - 1]} ${time.day}';

  static String formatWhenFieldDate(DateTime time, RepeatInterval interval) {
    if (interval == RepeatInterval.month) return '${time.day}';
    if (interval == RepeatInterval.year) return formatShortDate(time);
    return formatDateOnly(time);
  }

  static String formatMonthDayRange(DateTime start, DateTime end) {
    if (start.day == end.day) return '${start.day}';
    return '${start.day}–${end.day}';
  }

  static String formatYearDateRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${monthsShort[start.month - 1]} ${start.day}–${end.day}';
    }
    return '${formatShortDate(start)} – ${formatShortDate(end)}';
  }

  static String formatTime(DateTime time) =>
      '${pad(time.hour)}:${pad(time.minute)}';

  static String formatDateTime(DateTime time, {required bool isAllDay}) {
    if (isAllDay) return formatDateOnly(time);
    return '${formatDateOnly(time)} · ${formatTime(time)}';
  }

  static String repeatSummary({
    required RepeatInterval interval,
    required bool isAllDay,
    required DateTime startDate,
    required DateTime endDate,
    required Set<int> selectedDaysOfWeekIndices,
    required DateTime Function(DateTime) dateOnly,
  }) {
    switch (interval) {
      case RepeatInterval.week:
        if (selectedDaysOfWeekIndices.isEmpty) {
          return 'Select at least one day below';
        }
        const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final days = selectedDaysOfWeekIndices.toList()..sort();
        final names = days.map((i) => labels[i]).join(', ');
        if (isAllDay) return 'Every week on $names, all day';
        return 'Every week on $names, ${formatTime(startDate)}–${formatTime(endDate)}';
      case RepeatInterval.month:
        final range = dateOnly(endDate).isAfter(dateOnly(startDate))
            ? ' (${formatMonthDayRange(startDate, endDate)})'
            : ' on day ${startDate.day}';
        return 'Every month$range';
      case RepeatInterval.year:
        final range = dateOnly(endDate).isAfter(dateOnly(startDate))
            ? ' (${formatYearDateRange(startDate, endDate)})'
            : ' on ${formatShortDate(startDate)}';
        return 'Every year$range';
    }
  }

  static String repeatUntilSummary({
    required DateTime startDate,
    required DateTime repeatUntilDate,
    required DateTime Function(DateTime) dateOnly,
  }) {
    final start = dateOnly(startDate);
    final until = dateOnly(repeatUntilDate);
    final days = until.difference(start).inDays;
    if (days <= 0) return 'Last repetition is the same day as start';
    return 'Repeats until ${formatDateOnly(until)} ($days days)';
  }

  static String formatEventTime(StoredCalendarEvent event) {
    if (event.isAllDayEvent) return 'All day';
    return '${formatTime(event.startDate)} – ${formatTime(event.endDate)}';
  }

  static String formatOccurrenceTime(CalendarEventOccurrence occurrence) {
    if (occurrence.event.isAllDayEvent) return 'All day';
    return '${formatTime(occurrence.displayStart)} – ${formatTime(occurrence.displayEnd)}';
  }

  static String formatRecurrenceSummary(StoredCalendarEvent event) {
    final recurrence = event.recurrence;
    if (!event.isRecurring || recurrence == null) return '';

    final until = formatDateOnly(recurrence.until);
    switch (recurrence.frequency) {
      case EventRecurrenceFrequency.monthly:
        return 'Repeats monthly until $until';
      case EventRecurrenceFrequency.yearly:
        return 'Repeats yearly until $until';
      default:
        const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final days = recurrence.daysOfWeek.toList()..sort();
        if (days.isEmpty) return 'Repeats weekly until $until';
        final names = days.map((i) => labels[i]).join(', ');
        return 'Repeats weekly on $names until $until';
    }
  }
}
