import 'package:flutter/material.dart';
import 'package:orga1/core/habit/entity/habit_with_events.dart';

class HabitWeekMatrixCard extends StatelessWidget {
  final HabitWithEvents item;
  final DateTime targetDate; // Hand it today (or any selected focus day)
  final Function(DateTime day) onDayToggled;
  final VoidCallback? onEdit;

  const HabitWeekMatrixCard({
    super.key,
    required this.item,
    required this.targetDate,
    required this.onDayToggled,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;

    // 1. Calculate the absolute normalized baseline for "today"
    final todayNormalized = DateTime(targetDate.year, targetDate.month, targetDate.day);

    // 2. Derive the left boundary start point (Exactly 6 days ago)
    final DateTime rollingStartDay = todayNormalized.subtract(const Duration(days: 6));

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
          // --- HABIT HEADER (Icon & Title) ---
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
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.05), height: 1, thickness: 1),
          const SizedBox(height: 14),

          // --- ROLLING WEEK VIEW MATRIX (History on Left -> Present on Right) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Calculate day step for this specific slot index (Index 0 = 6 days ago, Index 6 = Today)
              final DateTime currentCellDay = rollingStartDay.add(Duration(days: index));
              
              // Dynamic structural completion validation checks
              final bool isDayCompleted = item.isCompletedOnDay(currentCellDay);
              final bool isCurrentTargetDay = currentCellDay.isAtSameMomentAs(todayNormalized);

              // 1. Define your localized lookup matrix at the top of your build method
              final List<String> manualWeekDays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];

              // ... inside your List.generate(7, (index) { ...
              // 3. Extract the name manually using the 1-indexed weekday property
              // We subtract 1 because our array index begins securely at 0
              final String dayLabel = manualWeekDays[currentCellDay.weekday - 1];

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Day Label with premium visual focus highlight for today
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
                    
                    // Interaction Anchor Node Bubble
                    InkWell(
                      onTap: () => onDayToggled(currentCellDay),
                      borderRadius: BorderRadius.circular(100),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(2),
                          decoration: isCurrentTargetDay
                              ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: habit.color.withOpacity(0.4), width: 1.5),
                                )
                              : null,
                          child: Icon(
                            isDayCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
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