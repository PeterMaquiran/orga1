import 'package:flutter/cupertino.dart';

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
    final bg = CupertinoColors.systemBackground.resolveFrom(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle (selection / today)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? active
                    : isToday
                        ? active.withValues(alpha: 0.08)
                        : bg,
                border: isToday && !isSelected
              ? Border.all(color: active.withValues(alpha: 0.55), width: 1.5)
              : null,
              ),
            ),

            // Day number
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
                color: isSelected
                    ? CupertinoColors.white
                    : isToday
                        ? active
                        : labelColor,
              ),
            ),

            // Event dot
            if (hasEvents)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? CupertinoColors.white
                        : active.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}