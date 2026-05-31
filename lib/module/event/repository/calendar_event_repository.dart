import 'package:hive_flutter/hive_flutter.dart';

import '../../../ui/screen/ios/calendar/models/stored_calendar_event.dart';

class CalendarEventRepository {
  CalendarEventRepository({Box? box}) : _box = box;

  static const boxName = 'calendarEventsBox';

  Box? _box;

  Box get box => _box ?? Hive.box(boxName);

  Future<List<StoredCalendarEvent>> getAll() async {
    return box.values
        .map(
          (raw) => StoredCalendarEvent.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  Future<void> insert(StoredCalendarEvent event) async {
    await box.put(event.id, event.toMap());
  }
}
