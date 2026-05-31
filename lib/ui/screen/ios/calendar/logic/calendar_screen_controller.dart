import 'package:flutter/foundation.dart';

import '../models/stored_calendar_event.dart';
import 'calendar_event_expander.dart';
import '../../../../../module/event/repository/calendar_event_repository.dart';

class CalendarScreenController extends ChangeNotifier {
  CalendarScreenController({
    CalendarEventRepository? repository,
    DateTime? initialSelected,
  })  : _repository = repository ?? CalendarEventRepository(),
        _selected = CalendarEventExpander.dateOnly(
          initialSelected ?? DateTime.now(),
        ) {
    _displayedMonth = DateTime(_selected.year, _selected.month);
  }

  final CalendarEventRepository _repository;

  late DateTime _selected;
  late DateTime _displayedMonth;
  List<StoredCalendarEvent> _events = [];
  bool _loading = true;

  DateTime get selected => _selected;
  DateTime get displayedMonth => _displayedMonth;
  bool get loading => _loading;
  List<StoredCalendarEvent> get events => _events;

  Set<DateTime> get eventDates {
    final rangeStart = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    final rangeEnd = DateTime(_displayedMonth.year, _displayedMonth.month + 2, 0);
    return CalendarEventExpander.datesWithEvents(_events, rangeStart, rangeEnd);
  }

  List<CalendarEventOccurrence> get selectedDayOccurrences =>
      CalendarEventExpander.occurrencesForDay(_events, _selected);

  Future<void> initialize() => refresh();

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _events = await _repository.getAll();
    _loading = false;
    notifyListeners();
  }

  void setSelected(DateTime date) {
    final next = CalendarEventExpander.dateOnly(date);
    if (next == _selected) return;
    _selected = next;
    _displayedMonth = DateTime(_selected.year, _selected.month);
    notifyListeners();
  }

  void setDisplayedMonth(DateTime month) {
    _displayedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  bool hasEventsOnDay(DateTime day) {
    final normalized = CalendarEventExpander.dateOnly(day);
    return eventDates.contains(normalized);
  }
}
