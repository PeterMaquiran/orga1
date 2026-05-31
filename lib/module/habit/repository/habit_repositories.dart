import 'package:hive_flutter/hive_flutter.dart';

import 'habit.repository.dart';
import 'habit_event.repository.dart';

/// Default repository instances backed by open Hive boxes.
class HabitRepositories {
  HabitRepositories({
    required this.habits,
    required this.events,
  });

  final HabitRepository habits;
  final HabitEventRepository events;

  factory HabitRepositories.fromHive() {
    final eventRepository = HabitEventRepository(Hive.box(HabitEventRepository.boxName));
    final habitRepository = HabitRepository(
      Hive.box(HabitRepository.boxName),
      eventRepository,
    );
    return HabitRepositories(
      habits: habitRepository,
      events: eventRepository,
    );
  }
}
