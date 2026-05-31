import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';

class HabitCard extends StatelessWidget {
  final int index;
  final HabitWithEvents item;
  final DateTime targetDate;
  final bool isSelected;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.index,
    required this.item,
    required this.targetDate,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;

    final double currentValue = item.getProgressForDay(targetDate);
    final double targetValue = habit.targetValue;
    final double progressPct = item.getCompletionRatioForDay(targetDate);
    final bool isCompleted = item.isCompletedOnDay(targetDate);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(  
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: false
              ? [
                  BoxShadow(
                    color: habit.color.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
          border: Border.all(
            color: false ? habit.color.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.goalType == 'checkmark'
                            ? (isCompleted ? "Completed today!" : "Pending action")
                            : "Goal: ${_formatValue(currentValue)} / ${_formatValue(targetValue)} ${habit.unit}",
                        style: TextStyle(
                          fontSize: 13,
                          color: isCompleted ? Colors.green.shade700 : Colors.black45,
                          fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (onTap != null)
                //   Icon(
                //     Icons.chevron_right,
                //     size: 18,
                //     color: Colors.black.withOpacity(0.25),
                //   ),
                const SizedBox(width: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: habit.goalType == 'checkmark'
                      ? EdgeInsets.zero
                      : const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: habit.goalType == 'checkmark'
                      ? null
                      : BoxDecoration(
                          color: isCompleted
                              ? Colors.green.shade400
                              : habit.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                  child: habit.goalType == 'checkmark'
                      ? Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green.shade400 : Colors.black26,
                          size: 28,
                        )
                      : Icon(
                          isCompleted ? Icons.check_outlined : Icons.add,
                          size: 20,
                          color: isCompleted ? Colors.white : habit.color,
                        ),
                ),
              ],
            ),
            if (habit.goalType != 'checkmark' && !isCompleted) ...[
              const SizedBox(height: 14),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progressPct,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: habit.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }
}
