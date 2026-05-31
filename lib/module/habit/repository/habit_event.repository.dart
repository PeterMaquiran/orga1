import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';
import 'package:uuid/uuid.dart';

class HabitEventRepository {
  HabitEventRepository(this._eventBox);

  static const boxName = 'habitEventsBox';

  final Box _eventBox;

  HabitEvent? _fromRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is HabitEvent) return raw;
    if (raw is Map) {
      return HabitEvent.fromStorage(raw);
    }
    return null;
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<List<HabitEvent>> getEventsInRange(DateTime start, DateTime end) async {
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    final events = <HabitEvent>[];
    for (final key in _eventBox.keys) {
      final event = _fromRaw(_eventBox.get(key));
      if (event == null) continue;
      final ts = event.timestamp;
      if (!ts.isBefore(normalizedStart) && !ts.isAfter(normalizedEnd)) {
        events.add(event);
      }
    }
    return events;
  }

  Future<Map<String, List<HabitEvent>>> getEventsGroupedByHabit(
    DateTime start,
    DateTime end,
  ) async {
    final events = await getEventsInRange(start, end);
    final grouped = <String, List<HabitEvent>>{};
    for (final event in events) {
      grouped.putIfAbsent(event.habitId, () => []).add(event);
    }
    return grouped;
  }

  Future<List<HabitEvent>> getEventsByHabit(String habitId) async {
    return _eventBox.values
        .map(_fromRaw)
        .whereType<HabitEvent>()
        .where((event) => event.habitId == habitId)
        .toList();
  }

  Future<void> insertEvent(HabitEvent event) async {
    await _eventBox.put(event.id, event.toStorage());
  }

  Future<void> deleteAllForHabit(String habitId) async {
    final keysToRemove = <dynamic>[];
    for (final key in _eventBox.keys) {
      final event = _fromRaw(_eventBox.get(key));
      if (event == null) continue;
      if (event.habitId == habitId) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      await _eventBox.delete(key);
    }
  }

  Future<void> deleteEventsForHabitOnDay(String habitId, DateTime day) async {
    final normalized = _normalizeDate(day);
    final keysToRemove = <dynamic>[];

    for (final key in _eventBox.keys) {
      final event = _fromRaw(_eventBox.get(key));
      if (event == null) continue;
      if (event.habitId != habitId) continue;
      final ts = event.timestamp;
      if (ts.year == normalized.year &&
          ts.month == normalized.month &&
          ts.day == normalized.day) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      await _eventBox.delete(key);
    }
  }

  Future<void> setProgressForDay({
    required String habitId,
    required DateTime day,
    required double value,
  }) async {
    await deleteEventsForHabitOnDay(habitId, day);
    if (value <= 0) return;

    final normalized = _normalizeDate(day);
    final id = const Uuid().v4();
    await insertEvent(
      HabitEvent(
        id: id,
        habitId: habitId,
        timestamp: normalized,
        valueLogged: value,
      ),
    );
  }
}
