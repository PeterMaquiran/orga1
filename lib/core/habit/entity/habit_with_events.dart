import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';

class HabitWithEvents {
  final HabitModel habit;
  final List<HabitEvent> rangeEvents;

  HabitWithEvents({
    required this.habit,
    required this.rangeEvents,
  });

  /// Calculates the total absolute progress logged on a single given calendar day.
  /// Used to drive the completion text and progress calculations.
  double getProgressForDay(DateTime date) {
    return rangeEvents
        .where((e) => e.timestamp.year == date.year && 
                      e.timestamp.month == date.month && 
                      e.timestamp.day == date.day)
        .fold(0.0, (sum, event) => sum + event.valueLogged);
  }

  /// Checks if the target goal has been fully reached or exceeded on a specific day.
  /// Perfect for determining if a calendar cell should render its full premium color fill.
  bool isCompletedOnDay(DateTime date) {
    return getProgressForDay(date) >= habit.targetValue;
  }

  /// Calculates the completion ratio for a given day (clamped neatly between 0.0 and 1.0).
  /// Perfect for driving high-end minimalist progress rings or fading gradients.
  double getCompletionRatioForDay(DateTime date) {
    if (habit.targetValue <= 0.0) return 0.0;
    final progress = getProgressForDay(date);
    return (progress / habit.targetValue).clamp(0.0, 1.0);
  }
}