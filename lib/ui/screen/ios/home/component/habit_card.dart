import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';

class HabitCard extends StatelessWidget {
  final int index;
  final HabitWithEvents item; // Pass the entire object
  final DateTime targetDate;  // The specific calendar day this card represents
  final bool isSelected;
  final VoidCallback onActionPressed;
  final VoidCallback? onEdit;

  const HabitCard({
    super.key,
    required this.index,
    required this.item,
    required this.targetDate,
    required this.isSelected,
    required this.onActionPressed,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;

    // Pull operational progress directly out of your micro logs via infrastructure entity helpers
    final double currentValue = item.getProgressForDay(targetDate);
    final double targetValue = habit.targetValue;
    final double progressPct = item.getCompletionRatioForDay(targetDate);
    final bool isCompleted = item.isCompletedOnDay(targetDate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
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
          color: isSelected ? habit.color.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
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
                        if (onEdit != null)
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.black.withOpacity(0.25),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Dynamic Action Control Block
              InkWell(
                onTap: onActionPressed,
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: habit.goalType == 'checkmark' 
                      ? EdgeInsets.zero 
                      : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: habit.goalType == 'checkmark'
                      ? null
                      : BoxDecoration(
                          color: isCompleted ? Colors.green.shade400 : habit.color.withOpacity(0.1),
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
              ),
            ],
          ),

          // Integrated Linear Progress Bar Slider (Hidden for simple checkmarks or completed tasks)
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
    );
  }

  String _formatValue(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }
}