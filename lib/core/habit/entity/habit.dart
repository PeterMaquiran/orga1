import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// This tells the builder to generate the binary adapter file
part 'habit.g.dart'; 

@HiveType(typeId: 0) // Assign a unique typeId (0-223) for this class
class HabitModel extends HiveObject {
  
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String emoji;

  @HiveField(3)
  final int colorValue; // Stored as int hex (e.g., 0xFF007AFF)

  @HiveField(4)
  final String goalType; // 'checkmark' or 'quantity'

  @HiveField(5)
  final String unit; // e.g., 'L', 'mins'

  @HiveField(6)
  final double targetValue;

  @HiveField(7)
  final String timeText;

  @HiveField(8)
  final List<bool> activeDays; // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]

  @HiveField(9)
  final String frequency; // 'Daily' or 'Weekly'

  HabitModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.colorValue,
    required this.goalType,
    required this.unit,
    required this.targetValue,
    required this.timeText,
    required this.activeDays,
    this.frequency = 'Daily',
  });

  // --- HELPER UTILITIES ---
  Color get color => Color(colorValue);

  // --- MODEL COPIES (IMMUTABILITY) ---
  HabitModel copyWith({
    String? id,
    String? title,
    String? emoji,
    int? colorValue,
    String? goalType,
    String? unit,
    double? targetValue,
    String? timeText,
    List<bool>? activeDays,
    String? frequency,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      colorValue: colorValue ?? this.colorValue,
      goalType: goalType ?? this.goalType,
      unit: unit ?? this.unit,
      targetValue: targetValue ?? this.targetValue,
      timeText: timeText ?? this.timeText,
      activeDays: activeDays ?? this.activeDays,
      frequency: frequency ?? this.frequency,
    );
  }

  // --- BACKEND MAP INTEGRATION (Keeps your future Sync clean) ---
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      emoji: map['emoji'] as String,
      colorValue: map['colorValue'] as int,
      goalType: map['goalType'] as String,
      unit: map['unit'] as String,
      targetValue: (map['targetValue'] as num).toDouble(),
      timeText: map['timeText'] as String,
      activeDays: List<bool>.from(map['activeDays'] ?? List.filled(7, true)),
      frequency: (map['frequency'] as String?) ?? 'Daily',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'emoji': emoji,
      'colorValue': colorValue,
      'goalType': goalType,
      'unit': unit,
      'targetValue': targetValue,
      'timeText': timeText,
      'activeDays': activeDays,
      'frequency': frequency,
    };
  }
}