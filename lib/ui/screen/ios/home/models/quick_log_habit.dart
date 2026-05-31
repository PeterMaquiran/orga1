import 'package:flutter/material.dart';
import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/core/habit/entity/habit_form_input.dart';
import 'package:orga1/core/habit/entity/habit_goal_type.dart';

class QuickLogHabit {
  const QuickLogHabit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.frequency,
    required this.activeDays,
    required this.goalType,
    required this.unit,
    required this.currentValue,
    required this.targetValue,
    required this.timeText,
    required this.notes,
  });

  final String id;
  final String title;
  final String emoji;
  final int colorValue;
  final String frequency;
  final List<bool> activeDays;
  final String goalType;
  final String unit;
  final double currentValue;
  final double targetValue;
  final String timeText;
  final String notes;

  Color get color => Color(colorValue);

  bool get isCheckmark => goalType == 'checkmark';

  factory QuickLogHabit.fromHabit(
    HabitModel habit, {
    double currentValue = 0,
    String notes = '',
  }) {
    return QuickLogHabit(
      id: habit.id,
      title: habit.title,
      emoji: habit.emoji,
      colorValue: habit.colorValue,
      frequency: habit.frequency,
      activeDays: List<bool>.from(habit.activeDays),
      goalType: habit.goalType,
      unit: habit.unit,
      currentValue: currentValue,
      targetValue: habit.targetValue,
      timeText: habit.timeText,
      notes: notes,
    );
  }

  HabitFormInput toFormInput() {
    return HabitFormInput(
      id: id.isEmpty ? null : id,
      title: title,
      emoji: emoji,
      colorValue: colorValue,
      frequency: frequency,
      activeDays: List<bool>.from(activeDays),
      goalType: HabitGoalType.fromStorage(goalType),
      targetValue: targetValue,
      unit: unit,
      timeText: timeText,
      notes: notes,
    );
  }

  QuickLogHabit copyWith({
    String? id,
    String? title,
    String? emoji,
    int? colorValue,
    String? frequency,
    List<bool>? activeDays,
    String? goalType,
    String? unit,
    double? currentValue,
    double? targetValue,
    String? timeText,
    String? notes,
  }) {
    return QuickLogHabit(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      activeDays: activeDays ?? this.activeDays,
      goalType: goalType ?? this.goalType,
      unit: unit ?? this.unit,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      timeText: timeText ?? this.timeText,
      notes: notes ?? this.notes,
    );
  }

  QuickLogHabit applyFormInput(HabitFormInput input) {
    return copyWith(
      id: input.id ?? id,
      title: input.title,
      emoji: input.emoji,
      colorValue: input.colorValue,
      frequency: input.frequency,
      activeDays: input.activeDays,
      goalType: input.goalType.storageKey,
      unit: input.unit,
      targetValue: input.goalType == HabitGoalType.checkmark
          ? 1.0
          : (input.targetValue ?? targetValue),
      timeText: input.timeText,
      notes: input.notes,
    );
  }
}
