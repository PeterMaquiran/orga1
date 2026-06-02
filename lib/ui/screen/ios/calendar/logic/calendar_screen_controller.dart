import 'package:flutter/foundation.dart';

import '../models/calendar_day_event_group.dart';
import '../models/calendar_event_list_mode.dart';
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
  bool _monthView = false;
  CalendarEventListMode _listMode = CalendarEventListMode.selectedDayOnly;

  DateTime get selected => _selected;
  DateTime get displayedMonth => _displayedMonth;
  bool get loading => _loading;
  bool get monthView => _monthView;
  CalendarEventListMode get listMode => _listMode;
  List<StoredCalendarEvent> get events => _events;



  void setMonthView(bool monthView) {
    if (_monthView == monthView) return;
    _monthView = monthView;
    notifyListeners();
  }

  void setListMode(CalendarEventListMode mode) {
    if (_listMode == mode) return;
    _listMode = mode;
    notifyListeners();
  }

  List<CalendarDayEventGroup> get eventGroups {
    switch (_listMode) {
      case CalendarEventListMode.selectedDayOnly:
        return _selectedDayEventGroups;
      case CalendarEventListMode.fromTodayForward:
        return _fromTodayForwardEventGroups;
    }
  }

  List<CalendarDayEventGroup> get _selectedDayEventGroups {
    final occurrences =
        CalendarEventExpander.occurrencesForDay(_events, _selected);
    if (occurrences.isEmpty) return [];
    return [
      CalendarDayEventGroup(day: _selected, occurrences: occurrences),
    ];
  }

  /// All event days in the calendar's currently displayed month.
  List<CalendarDayEventGroup> get _fromTodayForwardEventGroups {
    final y = _displayedMonth.year;
    final m = _displayedMonth.month;
    final start = CalendarEventExpander.dateOnly(DateTime(y, m, 1));
    final end = CalendarEventExpander.dateOnly(DateTime(y, m + 1, 0));

    final groups = <CalendarDayEventGroup>[];
    var cursor = start;

    while (!cursor.isAfter(end)) {
      final occurrences =
          CalendarEventExpander.occurrencesForDay(_events, cursor);
      if (occurrences.isNotEmpty) {
        groups.add(
          CalendarDayEventGroup(day: cursor, occurrences: occurrences),
        );
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return groups;
  }

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

  Future<void> deleteEvent(String id) async {
    await _repository.delete(id);
    await refresh();
  }
}
