import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MonthDayCell extends StatelessWidget {
  const MonthDayCell({
    super.key,
    required this.date,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.hasEvents = false,
  });

  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected ? active.withValues(alpha: 0.18) : Colors.transparent,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: active.withValues(alpha: 0.55), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
                color: inMonth ? (isSelected ? active : labelColor) : tertiary,
              ),
            ),
            if (hasEvents)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: isSelected ? active : active.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
