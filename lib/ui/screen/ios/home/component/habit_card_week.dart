import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';
import 'package:orga1/ui/shared/menu-achor.dart';

enum HabitWeekCardMenuAction { statistics, edit, delete }

class HabitWeekMatrixCard extends StatelessWidget {
  final HabitWithEvents item;
  final DateTime targetDate;
  final ValueChanged<DateTime> onDayTap;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onStatistics;
  /// `1` = previous week, `-1` = next week (when user swipes horizontally).
  final ValueChanged<int>? onWeekShift;

  const HabitWeekMatrixCard({
    super.key,
    required this.item,
    required this.targetDate,
    required this.onDayTap,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onStatistics,
    this.onWeekShift,
  });

  List<StatsMenuItem<HabitWeekCardMenuAction>> _menuItems() {
    return [
      StatsMenuItem(
        value: HabitWeekCardMenuAction.statistics,
        label: 'Statistics',
        icon: CupertinoIcons.chart_bar_alt_fill,
        onPressed: onStatistics,
      ),
      StatsMenuItem(
        value: HabitWeekCardMenuAction.edit,
        label: 'Edit Habit',
        icon: CupertinoIcons.pencil,
        onPressed: onEdit,
      ),
      if (onDelete != null) const StatsMenuItem.divider(),
      if (onDelete != null)
        StatsMenuItem(
          value: HabitWeekCardMenuAction.delete,
          label: 'Delete Habit',
          icon: CupertinoIcons.delete,
          isDestructive: true,
          onPressed: onDelete,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final habit = item.habit;

    final focusDayNormalized =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final now = DateTime.now();
    final realTodayNormalized = DateTime(now.year, now.month, now.day);
    final DateTime rollingStartDay =
        focusDayNormalized.subtract(const Duration(days: 6));

    return GestureDetector(
      onHorizontalDragEnd: onWeekShift == null
          ? null
          : (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -200) {
                onWeekShift!(-1);
              } else if (velocity > 200) {
                onWeekShift!(1);
              }
            },
      child: Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (){},
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
                          child: Text(
                            habit.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
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
                      // if (onTap != null)
                      //   Icon(
                      //     Icons.chevron_right,
                      //     size: 18,
                      //     color: Colors.black.withOpacity(0.25),
                      //   ),
                    ],
                  ),
                ),
              ),
              if (onEdit != null || onDelete != null)
                StatsMenuButton<HabitWeekCardMenuAction>(
                  icon: CupertinoIcons.ellipsis,
                  size: 36,
                  items: _menuItems(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.black.withOpacity(0.05), height: 1, thickness: 1),
          const SizedBox(height: 14),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final DateTime currentCellDay =
                    rollingStartDay.add(Duration(days: index));
                final bool isScheduled = habit.isActiveOnDay(currentCellDay);
                final double dayProgress = isScheduled
                    ? item.getProgressForDay(currentCellDay)
                    : 0;
                final double dayProgressRatio = isScheduled
                    ? item.getCompletionRatioForDay(currentCellDay)
                    : 0;
                final bool isDayCompleted =
                    isScheduled && item.isCompletedOnDay(currentCellDay);
                final bool isCheckmark = habit.isCheckmarkGoal;
                final bool isFocusDay =
                    currentCellDay.isAtSameMomentAs(focusDayNormalized);
                final bool isActualToday =
                    currentCellDay.isAtSameMomentAs(realTodayNormalized);
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
                        isActualToday ? "TODAY" : dayLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: !isScheduled
                              ? Colors.black.withOpacity(0.12)
                              : isFocusDay
                                  ? habit.color
                                  : Colors.black.withOpacity(0.35),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: isScheduled
                            ? () => onDayTap(currentCellDay)
                            : null,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(2),
                            decoration: isScheduled && isFocusDay
                                ? BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: habit.color.withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  )
                                : null,
                            child: _WeekDayCellIndicator(
                              isScheduled: isScheduled,
                              isCheckmark: isCheckmark,
                              isCompleted: isDayCompleted,
                              isFocusDay: isFocusDay,
                              progress: dayProgress,
                              progressRatio: dayProgressRatio,
                              color: habit.color,
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
    ),
    );
  }
}

class _WeekDayCellIndicator extends StatelessWidget {
  const _WeekDayCellIndicator({
    required this.isScheduled,
    required this.isCheckmark,
    required this.isCompleted,
    required this.isFocusDay,
    required this.progress,
    required this.progressRatio,
    required this.color,
  });

  final bool isScheduled;
  final bool isCheckmark;
  final bool isCompleted;
  final bool isFocusDay;
  final double progress;
  final double progressRatio;
  final Color color;

  String _formatValue(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    if (!isScheduled) {
      return Icon(
        Icons.radio_button_unchecked,
        color: Colors.black.withOpacity(0.08),
        size: 24,
      );
    }

    if (isCheckmark) {
      return Icon(
        isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
        color: isCompleted
            ? Colors.green.shade400
            : isFocusDay
                ? color.withOpacity(0.3)
                : Colors.black12,
        size: 24,
      );
    }

    if (isCompleted) {
      return Icon(
        Icons.check_circle_rounded,
        color: Colors.green.shade400,
        size: 24,
      );
    }

    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
              value: progressRatio.clamp(0.0, 1.0),
              strokeWidth: 2.5,
              backgroundColor: Colors.black.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(
                isFocusDay ? color : color.withOpacity(0.55),
              ),
          ),
          if (progress > 0)
            Text(
              _formatValue(progress),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isFocusDay ? color : Colors.black54,
                height: 1,
              ),
            ),
        ],
      ),
    );
  }
}
