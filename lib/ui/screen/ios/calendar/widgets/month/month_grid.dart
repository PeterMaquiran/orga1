import 'package:flutter/material.dart';

import '../../logic/calendar_date_utils.dart';
import '../../logic/month_grid_cells.dart';
import '../calendar_day_row.dart';
import 'month_day_cell.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selected,
    required this.onSelectDay,
    this.eventDates = const {},
  });

  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onSelectDay;
  final Set<DateTime> eventDates;

  @override
  Widget build(BuildContext context) {
    final y = month.year;
    final m = month.month;
    final cells = buildMonthGridCells(month);

    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: OrgaCalendarDateUtils.monthGridBottomPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < OrgaCalendarDateUtils.monthGridWeeks; row++)
            SizedBox(
              height: OrgaCalendarDateUtils.monthGridRowExtent,
              child: CalendarDayRow(
                children: [
                  for (int col = 0; col < 7; col++)
                    Builder(
                      builder: (context) {
                        final date = cells[row * 7 + col];
                        final inMonth = date.month == m && date.year == y;
                        return MonthDayCell(
                          date: date,
                          inMonth: inMonth,
                          isSelected: DateUtils.isSameDay(date, selected),
                          isToday: DateUtils.isSameDay(date, todayDay),
                          hasEvents: eventDates.contains(
                            OrgaCalendarDateUtils.dateOnly(date),
                          ),
                          onTap: () =>
                              onSelectDay(OrgaCalendarDateUtils.dateOnly(date)),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
