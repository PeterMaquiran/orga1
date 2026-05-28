import 'package:flutter/material.dart';

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

  factory QuickLogHabit.fromMap(Map<String, dynamic> map) {
    final rawColor = map['colorValue'] ?? map['color'];
    int parsedColor = 0xFF007AFF;
    if (rawColor is int) {
      parsedColor = rawColor;
    } else if (rawColor is Color) {
      parsedColor = rawColor.toARGB32();
    }

    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return QuickLogHabit(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      emoji: (map['emoji'] ?? '❤️').toString(),
      colorValue: parsedColor,
      frequency: (map['frequency'] ?? 'Daily').toString(),
      activeDays: List<bool>.from(map['activeDays'] ?? List.filled(7, true)),
      goalType: (map['goalType'] ?? 'checkmark').toString(),
      unit: (map['unit'] ?? '').toString(),
      currentValue: parseDouble(map['currentValue']),
      targetValue: parseDouble(map['targetValue']),
      timeText: (map['timeText'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'color': colorValue,
      'colorValue': colorValue,
      'frequency': frequency,
      'activeDays': List<bool>.from(activeDays),
      'goalType': goalType,
      'unit': unit,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'timeText': timeText,
      'notes': notes,
    };
  }
}
