import 'package:flutter/material.dart';

import '../logic/calendar_date_utils.dart';

/// Seven day columns with consistent spacing for header, week, and month rows.
class CalendarDayRow extends StatelessWidget {
  const CalendarDayRow({
    super.key,
    required this.children,
    this.cellExtent = OrgaCalendarDateUtils.monthGridRowExtent,
  });

  final List<Widget> children;
  final double cellExtent;

  @override
  Widget build(BuildContext context) {
    assert(children.length == 7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final child in children)
          SizedBox(
            width: cellExtent,
            height: cellExtent,
            child: child,
          ),
      ],
    );
  }
}
