import 'package:flutter/material.dart';

import 'calendar_date_utils.dart';

/// Builds the fixed 6×7 date list for a month grid (Monday-first).
List<DateTime> buildMonthGridCells(DateTime month) {
  final y = month.year;
  final m = month.month;
  final daysInMonth = DateUtils.getDaysInMonth(y, m);
  final firstWeekday = DateTime(y, m, 1).weekday - 1;

  final cells = <DateTime>[];
  final prevMonthLastDay = DateTime(y, m, 0).day;
  for (int i = 0; i < firstWeekday; i++) {
    final day = prevMonthLastDay - firstWeekday + i + 1;
    cells.add(DateTime(y, m - 1, day));
  }
  for (int d = 1; d <= daysInMonth; d++) {
    cells.add(DateTime(y, m, d));
  }
  while (cells.length < OrgaCalendarDateUtils.monthGridCellCount) {
    cells.add(
      DateTime(y, m + 1, cells.length - (firstWeekday + daysInMonth) + 1),
    );
  }
  return cells;
}
