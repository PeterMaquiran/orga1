import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';

class HabitWeekMatrixCard extends StatelessWidget {
  final HabitWithEvents item;
  final DateTime targetDate;
  final Function(DateTime day) onDayToggled;
  final VoidCallback? onTap;

  const HabitWeekMatrixCard({
    super.key,
    required this.item,
    required this.targetDate,
    required this.onDayToggled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;

    final todayNormalized =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final DateTime rollingStartDay =
        todayNormalized.subtract(const Duration(days: 6));

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(habit.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.black.withOpacity(0.25),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.05), height: 1, thickness: 1),
          const SizedBox(height: 14),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final DateTime currentCellDay =
                    rollingStartDay.add(Duration(days: index));
                final bool isDayCompleted = item.isCompletedOnDay(currentCellDay);
                final bool isCurrentTargetDay =
                    currentCellDay.isAtSameMomentAs(todayNormalized);
                const manualWeekDays = [
                  "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"
                ];
                final String dayLabel =
                    manualWeekDays[currentCellDay.weekday - 1];

                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isCurrentTargetDay ? "TODAY" : dayLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCurrentTargetDay
                              ? habit.color
                              : Colors.black.withOpacity(0.35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => onDayToggled(currentCellDay),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(2),
                            decoration: isCurrentTargetDay
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: habit.color.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                            child: Icon(
                              isDayCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: isDayCompleted
                                  ? Colors.green.shade400
                                  : isCurrentTargetDay
                                      ? habit.color.withOpacity(0.3)
                                      : Colors.black12,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
            }),
          ),
        ],
      ),
    );
  }
}
