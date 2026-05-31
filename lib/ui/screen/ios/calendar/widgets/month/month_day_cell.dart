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
    this.eventCount = 1, // Optional: defaults to 1 if hasEvents is true
  });

  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final bool hasEvents;
  final int eventCount;
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
              ? Border.all(color: active.withValues(alpha: 0.55), width: 1.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Day Number Label
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
                color: inMonth ? (isSelected ? active : labelColor) : tertiary,
              ),
            ),
            
            // Event Indicators
            if (hasEvents)
              Positioned(
                bottom: 5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    // Caps the dots at 3 so they don't overflow the circle
                    eventCount.clamp(1, 3), 
                    (index) => Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        color: isSelected ? active : active.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}