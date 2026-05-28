import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';
import 'package:orga1/core/habit/entity/habit_with_events.dart';
import 'package:orga1/ui/screen/ios/home/models/quick_log_habit.dart';
import 'package:uuid/uuid.dart';

import '../models/home_view_mode.dart';

class HomeController extends ChangeNotifier {
  HomeController() {
    final now = DateTime.now();
    _focusDate = DateTime(now.year, now.month, now.day);
  }

  HomeViewMode _viewMode = HomeViewMode.day;
  late DateTime _focusDate;
  List<HabitWithEvents> _habits = [];
  String? _selectedHabitId;
  bool _loadingHabits = true;

  HomeViewMode get viewMode => _viewMode;
  DateTime get focusDate => _focusDate;
  List<HabitWithEvents> get habits => _habits;
  String? get selectedHabitId => _selectedHabitId;
  bool get loadingHabits => _loadingHabits;

  Future<void> initialize() async {
    await _loadHabits();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  ({DateTime start, DateTime end}) _eventRangeForMode() {
    final focus = _normalizeDate(_focusDate);
    if (_viewMode == HomeViewMode.week) {
      final start = focus.subtract(const Duration(days: 6));
      return (
        start: start,
        end: DateTime(focus.year, focus.month, focus.day, 23, 59, 59),
      );
    }
    return (
      start: focus,
      end: DateTime(focus.year, focus.month, focus.day, 23, 59, 59),
    );
  }

  HabitEvent? _eventFromRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is HabitEvent) return raw;
    if (raw is Map) {
      return HabitEvent.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<void> _loadHabits() async {
    final habitBox = Hive.box('habitsBox');
    final eventBox = Hive.box('habitEventsBox');
    final range = _eventRangeForMode();
    final normalizedStart =
        DateTime(range.start.year, range.start.month, range.start.day);
    final normalizedEnd = range.end;

    final habits = habitBox.values
        .map((raw) => HabitModel.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();

    final events = <HabitEvent>[];
    for (final key in eventBox.keys) {
      final event = _eventFromRaw(eventBox.get(key));
      if (event == null) continue;
      final ts = event.timestamp;
      if (!ts.isBefore(normalizedStart) && !ts.isAfter(normalizedEnd)) {
        events.add(event);
      }
    }

    final grouped = <String, List<HabitEvent>>{};
    for (final event in events) {
      grouped.putIfAbsent(event.habitId, () => []).add(event);
    }

    _habits = habits
        .map(
          (habit) => HabitWithEvents(
            habit: habit,
            rangeEvents: grouped[habit.id] ?? [],
          ),
        )
        .toList();
    _selectedHabitId ??= _habits.isNotEmpty ? _habits.first.habit.id : null;
    _loadingHabits = false;
    notifyListeners();
  }

  Future<void> setViewMode(HomeViewMode mode) async {
    if (_viewMode == mode) return;
    _viewMode = mode;
    _loadingHabits = true;
    notifyListeners();
    await _loadHabits();
  }

  Future<void> setFocusDate(DateTime date) async {
    final normalized = _normalizeDate(date);
    if (normalized == _focusDate) return;
    _focusDate = normalized;
    _loadingHabits = true;
    notifyListeners();
    await _loadHabits();
  }

  void selectHabit(String habitId) {
    if (_selectedHabitId == habitId) return;
    _selectedHabitId = habitId;
    notifyListeners();
  }

  QuickLogHabit habitToQuickLogHabit(HabitWithEvents item) {
    final habit = item.habit;
    return QuickLogHabit(
      id: habit.id,
      title: habit.title,
      emoji: habit.emoji,
      colorValue: habit.colorValue,
      frequency: habit.frequency,
      activeDays: List<bool>.from(habit.activeDays),
      goalType: habit.goalType,
      unit: habit.unit,
      currentValue: item.getProgressForDay(_focusDate),
      targetValue: habit.targetValue,
      timeText: habit.timeText,
      notes: '',
    );
  }

  Future<void> persistProgress(
    HabitWithEvents item,
    DateTime day,
    double value,
  ) async {
    final eventBox = Hive.box('habitEventsBox');
    final normalized = _normalizeDate(day);

    final keysToRemove = <dynamic>[];
    for (final key in eventBox.keys) {
      final event = _eventFromRaw(eventBox.get(key));
      if (event == null) continue;
      if (event.habitId != item.habit.id) continue;
      final ts = event.timestamp;
      if (ts.year == normalized.year &&
          ts.month == normalized.month &&
          ts.day == normalized.day) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      await eventBox.delete(key);
    }

    if (value > 0) {
      final id = const Uuid().v4();
      await eventBox.put(id, {
        'id': id,
        'habitId': item.habit.id,
        'timestamp': normalized.toIso8601String(),
        'valueLogged': value,
        'note': null,
      });
    }

    await _loadHabits();
  }

  Future<void> toggleDay(HabitWithEvents item, DateTime day) async {
    final completed = item.isCompletedOnDay(day);
    final nextValue = completed ? 0.0 : item.habit.targetValue;
    await persistProgress(item, day, nextValue);
  }

  Future<void> updateHabitFromQuickLog(QuickLogHabit updatedHabit) async {
    if (updatedHabit.id.isEmpty) return;

    final habitBox = Hive.box('habitsBox');
    final raw = habitBox.get(updatedHabit.id);
    if (raw is! Map) return;

    final current = Map<String, dynamic>.from(raw);
    current['title'] = updatedHabit.title;
    current['emoji'] = updatedHabit.emoji;
    current['goalType'] = updatedHabit.goalType;
    current['unit'] = updatedHabit.unit;
    current['timeText'] = updatedHabit.timeText;
    current['frequency'] = updatedHabit.frequency;
    current['colorValue'] = updatedHabit.colorValue;
    current['targetValue'] = updatedHabit.targetValue;
    current['activeDays'] = List<bool>.from(updatedHabit.activeDays);

    await habitBox.put(updatedHabit.id, current);
    await _loadHabits();
  }
}
