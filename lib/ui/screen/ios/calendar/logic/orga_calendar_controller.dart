import 'package:flutter/material.dart';
import 'package:orga1/module/event/event_service.dart';
import 'package:orga1/ui/screen/ios/calendar/logic/calendar_event_expander.dart';
import 'package:orga1/ui/screen/ios/calendar/models/stored_calendar_event.dart';

import 'calendar_date_utils.dart';

class OrgaCalendarController extends ChangeNotifier {
  List<StoredCalendarEvent> _events = [];

  OrgaCalendarController({
    required DateTime initialSelected,
    bool initialMonthView = false,
  })  : _selected = OrgaCalendarDateUtils.dateOnly(initialSelected),
        _monthView = initialMonthView {
    _displayedMonth = DateTime(_selected.year, _selected.month);
    _monthAnchor = _displayedMonth;
    weekPageController = PageController(initialPage: virtualCenter);
    monthPageController = PageController(initialPage: virtualCenter);

    EventService.listenFromHive().addListener(() {
      notifyListeners();
    });
  }

  Set<DateTime> get eventDates  {
    _events = EventService.getAll();
    final rangeStart =
        DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    final rangeEnd =
        DateTime(_displayedMonth.year, _displayedMonth.month + 2, 0);
    return CalendarEventExpander.datesWithEvents(_events, rangeStart, rangeEnd);
  }
  
  static const int virtualCenter = 10000;

  late final PageController weekPageController;
  late final PageController monthPageController;

  late DateTime _selected;
  late DateTime _displayedMonth;
  late DateTime _monthAnchor;
  bool _monthView;

  DateTime get selected => _selected;
  DateTime get displayedMonth => _displayedMonth;
  bool get monthView => _monthView;

  void setSelected(DateTime date) {
    final next = OrgaCalendarDateUtils.dateOnly(date);
    if (next == _selected) return;
    _selected = next;
    _displayedMonth = DateTime(_selected.year, _selected.month);
    _syncMonthPage(animate: false);
    notifyListeners();
  }

  void setMonthView(bool value) {
    if (_monthView == value) return;
    _monthView = value;
    if (!value) {
      _alignSelectedToDisplayedMonth();
    }
    notifyListeners();
    if (!value) {
      jumpToSelectedWeek();
    }
  }

  void jumpToSelectedWeek() {
    if (!weekPageController.hasClients) return;
    weekPageController.jumpToPage(pageForSelected());
  }

  int pageForSelected() {
    return virtualCenter +
        OrgaCalendarDateUtils.weekDifference(
          DateTime.now(),
          _selected,
        );
  }

  List<DateTime> weekDaysForPage(int index) {
    final today = DateTime.now();
    final anchorWeekStart = OrgaCalendarDateUtils.startOfWeek(
      OrgaCalendarDateUtils.dateOnly(today),
    );
    final offset = index - virtualCenter;
    final weekStart = anchorWeekStart.add(Duration(days: offset * 7));
    return List.generate(7, (i) => weekStart.add(Duration(days: i)));
  }

  DateTime selectedForWeekPage(int pageIndex) {
    final week = weekDaysForPage(pageIndex);
    for (final d in week) {
      if (d.weekday == _selected.weekday) {
        return OrgaCalendarDateUtils.dateOnly(d);
      }
    }
    return OrgaCalendarDateUtils.dateOnly(week.first);
  }

  DateTime monthForPage(int index) {
    final offset = index - virtualCenter;
    return DateTime(_monthAnchor.year, _monthAnchor.month + offset);
  }

  int pageForMonth(DateTime month) {
    return virtualCenter +
        (month.year - _monthAnchor.year) * 12 +
        (month.month - _monthAnchor.month);
  }

  void onMonthPageChanged(int index) {
    final month = monthForPage(index);
    final normalized = DateTime(month.year, month.month);
    if (normalized == _displayedMonth) return;
    _displayedMonth = normalized;
    notifyListeners();
  }

  void goToMonth(int delta) {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    _displayedMonth = next;
    notifyListeners();
    if (monthPageController.hasClients) {
      monthPageController.animateToPage(
        pageForMonth(next),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void syncToSelectedMonth({required bool animate}) {
    final pickedMonth = DateTime(_selected.year, _selected.month);
    if (pickedMonth != _displayedMonth) {
      _displayedMonth = pickedMonth;
      notifyListeners();
    }
    _syncMonthPage(animate: animate);
  }

  void _alignSelectedToDisplayedMonth() {
    if (_selected.year == _displayedMonth.year &&
        _selected.month == _displayedMonth.month) {
      return;
    }
    final maxDay =
        DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);
    final safeDay = _selected.day > maxDay ? maxDay : _selected.day;
    _selected = DateTime(_displayedMonth.year, _displayedMonth.month, safeDay);
  }

  void _syncMonthPage({required bool animate}) {
    if (!monthPageController.hasClients) return;
    final target = pageForMonth(_displayedMonth);
    if (animate) {
      monthPageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      monthPageController.jumpToPage(target);
    }
  }

  @override
  void dispose() {
    weekPageController.dispose();
    monthPageController.dispose();
    EventService.listenFromHive().removeListener(() {
      notifyListeners();
    });
    super.dispose();
  }
}
