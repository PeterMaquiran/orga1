import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';
import 'package:orga1/core/habit/entity/habit_with_events.dart';

class HabitRepository {
  final Box _habitBox;
  final Box<HabitEvent> _eventBox; // Inject both boxes here
  HabitRepository(this._habitBox, this._eventBox);

  @override
  Future<List<HabitModel>> getAllHabits() async {
    return _habitBox.values.map((item) {
      return HabitModel.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();
  }


  /// Fetches all active habits and stitches their corresponding transaction logs 
  /// for a given timeframe, returning a unified dataset directly to your BLoC / Cubit.
  Future<List<HabitWithEvents>> getHabitsWithEventsRange(DateTime start, DateTime end) async {
    // 1. Fetch raw habits and map them to domain objects
    final List<HabitModel> habits = _habitBox.values.map((item) {
      return HabitModel.fromMap(Map<String, dynamic>.from(item as Map));
    }).toList();

    // 2. Isolate and normalize range constraints
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    // 3. Filter and group events by habitId key locally in memory
    final Map<String, List<HabitEvent>> groupedEvents = {};
    
    final filteredEvents = _eventBox.values.where((event) =>
        event.timestamp.isAfter(normalizedStart) && 
        event.timestamp.isBefore(normalizedEnd));

    for (var event in filteredEvents) {
      groupedEvents.putIfAbsent(event.habitId, () => []).add(event);
    }

    // 4. Stitch the relational graph models together
    return habits.map((habit) {
      return HabitWithEvents(
        habit: habit,
        rangeEvents: groupedEvents[habit.id] ?? [],
      );
    }).toList();
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    final raw = _habitBox.get(id);
    if (raw == null) return null;
    return HabitModel.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<void> saveHabit(HabitModel habit) async {
    await _habitBox.put(habit.id, habit.toMap());
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }
}