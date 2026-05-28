import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class HabitSeeder {
  /// Your exact raw mock data array converted for your production schema
static const List<Map<String, dynamic>> _mockSource = [
    {
      'id': 'seed_habit_water',
      'title': 'Drink Clean Water',
      'emoji': '💧',
      'colorValue': 0xFF007AFF, // iOS Classic Blue
      'goalType': 'liters',
      'unit': 'L',
      'mockValue': 1.5,
      'targetValue': 3.0,
      'timeText': '07:30 AM'
    },
    {
      'id': 'seed_habit_meditation',
      'title': 'Morning Meditation',
      'emoji': '🧘',
      'colorValue': 0xFF5856D6, // Deep Violet
      'goalType': 'time',
      'unit': 'min',
      'mockValue': 20.0,
      'targetValue': 20.0,
      'timeText': '08:00 AM'
    },
    {
      'id': 'seed_habit_vitamins',
      'title': 'Take Core Vitamins',
      'emoji': '💊',
      'colorValue': 0xFF34C759, // Clean Green
      'goalType': 'checkmark',
      'unit': '',
      'mockValue': 1.0, // 1.0 means checked/completed
      'targetValue': 1.0,
      'timeText': '07:00 AM'
    },
    {
      'id': 'seed_habit_reading',
      'title': 'Read Technical Books',
      'emoji': '📚',
      'colorValue': 0xFFFF9500, // Premium Orange
      'goalType': 'pages',
      'unit': 'pages',
      'mockValue': 12.0,
      'targetValue': 25.0,
      'timeText': '09:00 PM'
    },
    {
      'id': 'seed_habit_running',
      'title': 'Cardio Run Track',
      'emoji': '🏃',
      'colorValue': 0xFFFF2D55, // Apple Rose/Pink
      'goalType': 'distance',
      'unit': 'km',
      'mockValue': 0.0, // Not started today yet
      'targetValue': 5.0,
      'timeText': '06:30 AM'
    },
    {
      'id': 'seed_habit_journal',
      'title': 'Daily Clear Reflection',
      'emoji': '✍️',
      'colorValue': 0xFFAF52DE, // Soft Indigo
      'goalType': 'checkmark',
      'unit': '',
      'mockValue': 0.0,
      'targetValue': 1.0,
      'timeText': '10:00 PM'
    },
    {
      'id': 'seed_habit_sleep',
      'title': 'Deep Rest Sleep',
      'emoji': '🌙',
      'colorValue': 0xFF1F2147, // Midnight Navy
      'goalType': 'time',
      'unit': 'hours',
      'mockValue': 7.5,
      'targetValue': 8.0,
      'timeText': '11:00 PM'
    },
    {
      'id': 'seed_habit_code',
      'title': 'Side Project Coding',
      'emoji': '💻',
      'colorValue': 0xFF5AC8FA, // Light Slate Blue
      'goalType': 'time',
      'unit': 'min',
      'mockValue': 45.0,
      'targetValue': 60.0,
      'timeText': '06:00 PM'
    },
    {
      'id': 'seed_habit_stretch',
      'title': 'Posture Stretching',
      'emoji': '🤸',
      'colorValue': 0xFFFFCC00, // Vibrant Yellow
      'goalType': 'checkmark',
      'unit': '',
      'mockValue': 1.0, // Completed early
      'targetValue': 1.0,
      'timeText': '12:00 PM'
    },
    {
      'id': 'seed_habit_meals',
      'title': 'Clean Whole Food Diet',
      'emoji': '🥗',
      'colorValue': 0xFF4CD964, // Mint Green
      'goalType': 'quantity',
      'unit': 'meals',
      'mockValue': 2.0,
      'targetValue': 3.0,
      'timeText': '01:00 PM'
    }
  ];
  
  /// Runs automatically on boot to seed boxes if empty
  static Future<void> seedIfEmpty({required Box habitBox, required Box eventBox}) async {
    if (habitBox.isNotEmpty) return; // Securely stop if data exists

    final uuid = const Uuid();
    final today = DateTime.now();

    for (var mock in _mockSource) {
      final String habitId = mock['id'] as String;

      // 1. Save local habit config configuration to disk
      await habitBox.put(habitId, {
        'id': habitId,
        'title': mock['title'],
        'emoji': mock['emoji'],
        'colorValue': mock['colorValue'],
        'goalType': mock['goalType'],
        'unit': mock['unit'],
        'targetValue': mock['targetValue'],
        'timeText': mock['timeText'],
        'activeDays': List<bool>.filled(7, true),
      });

      // 2. Turn the original 'currentValue' mock into an immediate history event log
      final double initialProgress = mock['mockValue'] as double;
      if (initialProgress > 0) {
        final String eventId = uuid.v4();
        await eventBox.put(eventId, {
          'id': eventId,
          'habitId': habitId,
          'timestamp': today.toIso8601String(),
          'valueLogged': initialProgress,
          'note': 'Seeded local record log',
        });
      }
    }
  }
}