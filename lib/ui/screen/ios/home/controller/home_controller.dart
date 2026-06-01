import 'package:flutter/foundation.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_form_input.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';
import 'package:orga1/module/habit/repository/habit_repositories.dart';
import 'package:orga1/ui/screen/ios/home/models/quick_log_habit.dart';

import '../models/home_view_mode.dart';

class HomeController extends ChangeNotifier {
  HomeController({HabitRepositories? repositories})
      : _repositories = repositories ?? HabitRepositories.fromHive() {
    final now = DateTime.now();
    _focusDate = DateTime(now.year, now.month, now.day);
  }

  final HabitRepositories _repositories;

  HomeViewMode _viewMode = HomeViewMode.day;
  late DateTime _focusDate;
  List<HabitWithEvents> _habits = [];
  String? _selectedHabitId;
  bool _loadingHabits = true;

  HomeViewMode get viewMode => _viewMode;
  DateTime get focusDate => _focusDate;
  List<HabitWithEvents> get habits => _habits;

  /// Day view: only habits scheduled on [focusDate]. Week view: all habits.
  List<HabitWithEvents> get visibleHabits {
    if (_viewMode == HomeViewMode.week) return _habits;
    return _habits
        .where((item) => item.habit.isActiveOnDay(_focusDate))
        .toList();
  }

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

  Future<void> _loadHabits() async {
    final range = _eventRangeForMode();
    _habits = await _repositories.habits.getHabitsWithEventsRange(
      range.start,
      range.end,
    );
    _syncSelectedHabit();
    _loadingHabits = false;
    notifyListeners();
  }

  void _syncSelectedHabit() {
    final visible = visibleHabits;
    if (_selectedHabitId != null &&
        !visible.any((item) => item.habit.id == _selectedHabitId)) {
      _selectedHabitId = null;
    }
    _selectedHabitId ??= visible.isNotEmpty ? visible.first.habit.id : null;
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

  QuickLogHabit habitToQuickLogHabit(
    HabitWithEvents item, {
    DateTime? day,
  }) {
    final logDay = day ?? _focusDate;
    return QuickLogHabit.fromHabit(
      item.habit,
      currentValue: item.getProgressForDay(logDay),
    );
  }

  Future<void> persistProgress(
    HabitWithEvents item,
    DateTime day,
    double value,
  ) async {
    await _repositories.events.setProgressForDay(
      habitId: item.habit.id,
      day: day,
      value: value,
    );
    await _loadHabits();
  }

  Future<void> toggleDay(HabitWithEvents item, DateTime day) async {
    if (!item.habit.isActiveOnDay(day)) return;
    final completed = item.isCompletedOnDay(day);
    final nextValue = completed ? 0.0 : item.habit.targetValue;
    await persistProgress(item, day, nextValue);
  }

  Future<void> updateHabitFromQuickLog(QuickLogHabit updatedHabit) async {
    await saveHabit(updatedHabit.toFormInput());
  }

  Future<void> saveHabit(HabitFormInput input) async {
    final isNew = input.isNew;
    final habit = await _repositories.habits.saveFormInput(input);
    if (isNew) {
      _selectedHabitId = habit.id;
    }
    await _loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _repositories.habits.deleteHabit(id);
    if (_selectedHabitId == id) {
      _selectedHabitId = null;
    }
    await _loadHabits();
  }
}
