import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';

class HabitEventRepository {
  // Target your specialized events storage box directly
  final Box<HabitEvent> _eventBox; 
  
  HabitEventRepository(this._eventBox);

  /// 1. Insert a standalone event transaction directly into the events table
  Future<void> insertEvent(HabitEvent event) async {
    // Save the event transaction using its unique event ID as the key
    await _eventBox.put(event.id, event);
  }

  /// 2. Get all historical event entries belonging to one single habit ID
  Future<List<HabitEvent>> getEventsByHabit(String habitId) async {
    return _eventBox.values
        .where((event) => event.habitId == habitId)
        .toList();
  }

  /// 3. Fetch all logged events across the entire app within a specific timeframe
  Future<List<HabitEvent>> getEventsInRange(DateTime start, DateTime end) async {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return _eventBox.values.where((event) {
      return event.timestamp.isAfter(normalizedStart) && 
             event.timestamp.isBefore(normalizedEnd);
    }).toList();
  }

  /// 4. Fetch events for a date window and map them specifically by Habit ID for your Week View grid
  Future<Map<String, List<HabitEvent>>> getWeeklyEventsGroupedByHabit(
      DateTime start, DateTime end) async {
    
    // Grab matching timestamp records across the range
    final List<HabitEvent> filteredEvents = await getEventsInRange(start, end);
    
    // Group records by habitId key: { "habit_id_abc": [Event1, Event2] }
    final Map<String, List<HabitEvent>> groupedMap = {};

    for (var event in filteredEvents) {
      if (!groupedMap.containsKey(event.habitId)) {
        groupedMap[event.habitId] = [];
      }
      groupedMap[event.habitId]!.add(event);
    }

    return groupedMap;
  }
}