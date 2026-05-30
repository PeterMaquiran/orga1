import 'package:flutter/cupertino.dart';

import '../../logic/calendar_date_utils.dart';

class CalendarWeekDayCell extends StatelessWidget {
  const CalendarWeekDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
    this.hasEvents = false,
  });

  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final highlight = isToday || isSelected;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: OrgaCalendarDateUtils.monthGridRowExtent,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF3C3C43).withOpacity(0.12),
            width: 1,
          ),
          color: isToday
              ? active.withOpacity(0.05)
              : CupertinoColors.systemBackground.resolveFrom(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: highlight ? active : labelColor,
              ),
            ),
            if (hasEvents)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: active.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
