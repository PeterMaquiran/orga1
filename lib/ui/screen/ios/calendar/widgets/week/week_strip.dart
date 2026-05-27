import 'package:flutter/material.dart';

import '../../logic/calendar_date_utils.dart';
import '../calendar_day_row.dart';
import 'week_day_cell.dart';

class CalendarWeekStrip extends StatelessWidget {
  const CalendarWeekStrip({
    super.key,
    required this.today,
    required this.selected,
    required this.pageController,
    required this.weekDaysForPage,
    required this.onWeekPageChanged,
    required this.onDayTap,
  });

  final DateTime today;
  final DateTime selected;
  final PageController pageController;
  final List<DateTime> Function(int index) weekDaysForPage;
  final ValueChanged<int> onWeekPageChanged;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: OrgaCalendarDateUtils.weekStripBottomPadding,
      ),
      child: SizedBox(
        height: OrgaCalendarDateUtils.monthGridRowExtent,
        child: PageView.builder(
          controller: pageController,
          onPageChanged: onWeekPageChanged,
          itemBuilder: (context, index) {
            final week = weekDaysForPage(index);
            return CalendarDayRow(
              children: [
                for (final date in week)
                  CalendarWeekDayCell(
                    date: date,
                    isToday: date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day,
                    isSelected: date.year == selected.year &&
                        date.month == selected.month &&
                        date.day == selected.day,
                    onTap: () => onDayTap(date),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
