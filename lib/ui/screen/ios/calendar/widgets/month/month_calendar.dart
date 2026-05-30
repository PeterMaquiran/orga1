import 'package:flutter/material.dart';

import '../../logic/calendar_date_utils.dart';
import 'month_grid.dart';

class OrgaMonthCalendar extends StatelessWidget {
  const OrgaMonthCalendar({
    super.key,
    required this.selected,
    required this.monthPageController,
    required this.onSelectDay,
    required this.onPageChanged,
    required this.monthForPage,
    this.eventDates = const {},
  });

  final DateTime selected;
  final PageController monthPageController;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<int> onPageChanged;
  final DateTime Function(int) monthForPage;
  final Set<DateTime> eventDates;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          height: OrgaCalendarDateUtils.monthGridHeight,
          child: PageView.builder(
            controller: monthPageController,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return MonthGrid(
                month: monthForPage(index),
                selected: selected,
                onSelectDay: onSelectDay,
                eventDates: eventDates,
              );
            },
          ),
        ),
      ],
    );
  }
}
