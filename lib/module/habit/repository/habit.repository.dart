import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_form_input.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_with_events.dart';
import 'package:uuid/uuid.dart';

import 'habit_event.repository.dart';

class HabitRepository {
  HabitRepository(this._habitBox, this._eventRepository);

  static const boxName = 'habitsBox';

  final Box _habitBox;
  final HabitEventRepository _eventRepository;

  Future<List<HabitModel>> getAllHabits() async {
    return _habitBox.values
        .map((item) => HabitModel.fromStorage(item))
        .toList();
  }

  Future<List<HabitWithEvents>> getHabitsWithEventsRange(
    DateTime start,
    DateTime end,
  ) async {
    final habits = await getAllHabits();
    final grouped = await _eventRepository.getEventsGroupedByHabit(start, end);

    return habits
        .map(
          (habit) => HabitWithEvents(
            habit: habit,
            rangeEvents: grouped[habit.id] ?? [],
          ),
        )
        .toList();
  }

  Future<HabitModel?> getHabitById(String id) async {
    final raw = _habitBox.get(id);
    if (raw == null) return null;
    return HabitModel.fromStorage(raw);
  }

  Future<void> saveHabit(HabitModel habit) async {
    await _habitBox.put(habit.id, habit.toStorage());
  }

  Future<HabitModel> saveFormInput(HabitFormInput input) async {
    final habitId = input.isNew ? const Uuid().v4() : input.id!.trim();
    final habit = input.toModel(habitId: habitId);
    await saveHabit(habit);
    return habit;
  }

  Future<void> deleteHabit(String id) async {
    await _habitBox.delete(id);
  }
}
