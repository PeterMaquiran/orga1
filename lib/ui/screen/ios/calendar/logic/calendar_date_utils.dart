/// Week math for the custom calendar (Monday-first).
abstract final class OrgaCalendarDateUtils {
  OrgaCalendarDateUtils._();

  static const List<String> weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  /// Fixed month grid size so the calendar does not resize between months.
  static const int monthGridWeeks = 6;
  static const int monthGridCellCount = monthGridWeeks * 7;
  static const double monthGridRowExtent = 35;
  static const double monthGridBottomPadding = 8;
  static const double monthGridHeight =
      monthGridWeeks * monthGridRowExtent + monthGridBottomPadding;

  static const double weekStripBottomPadding = 8;

  /// Column index for [weekdayLabels] (Monday = 0, Sunday = 6).
  static int weekdayColumnIndex(DateTime date) => date.weekday - 1;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// First day (Monday) of the calendar week containing [date] (midnight).
  static DateTime startOfWeek(DateTime date) {
    return dateOnly(date).subtract(Duration(days: date.weekday - 1));
  }

  /// Whole weeks between the week of [a] and the week of [b] (can be negative).
  static int weekDifference(DateTime a, DateTime b) {
    final DateTime sa = startOfWeek(a);
    final DateTime sb = startOfWeek(b);
    return sb.difference(sa).inDays ~/ 7;
  }
}
