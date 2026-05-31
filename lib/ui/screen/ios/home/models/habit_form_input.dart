import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_goal_type.dart';

/// Typed payload for creating or updating a habit from the UI.
class HabitFormInput {
  const HabitFormInput({
    this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.frequency,
    required this.activeDays,
    required this.goalType,
    this.targetValue,
    this.unit = '',
    this.timeText = '',
    this.notes = '',
  });

  final String? id;
  final String title;
  final String emoji;
  final int colorValue;
  final String frequency;
  final List<bool> activeDays;
  final HabitGoalType goalType;
  final double? targetValue;
  final String unit;
  final String timeText;
  final String notes;

  bool get isNew => id == null || id!.trim().isEmpty;

  factory HabitFormInput.fromHabit(HabitModel habit, {String notes = ''}) {
    return HabitFormInput(
      id: habit.id,
      title: habit.title,
      emoji: habit.emoji,
      colorValue: habit.colorValue,
      frequency: habit.frequency,
      activeDays: List<bool>.from(habit.activeDays),
      goalType: HabitGoalType.fromStorage(habit.goalType),
      targetValue: habit.targetValue,
      unit: habit.unit,
      timeText: habit.timeText,
      notes: notes,
    );
  }

  HabitModel toModel({required String habitId}) {
    final resolvedTarget = goalType == HabitGoalType.checkmark
        ? 1.0
        : (targetValue ?? 1.0);

    return HabitModel(
      id: habitId,
      title: title.trim(),
      emoji: emoji,
      colorValue: colorValue,
      goalType: goalType.storageKey,
      unit: unit.trim().isNotEmpty ? unit.trim() : goalType.defaultUnit,
      targetValue: resolvedTarget,
      timeText: timeText,
      activeDays: List<bool>.from(activeDays),
      frequency: frequency,
    );
  }
}
