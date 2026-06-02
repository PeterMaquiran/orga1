import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/module/event/event_service.dart';

import '../logic/calendar_date_utils.dart';
import '../logic/orga_calendar_controller.dart';
import 'month/month_calendar.dart';
import 'week/week_strip.dart';
import 'weekday_header_row.dart';

class OrgaWeekMonthCalendar extends StatefulWidget {
  const OrgaWeekMonthCalendar({
    super.key,
    required this.selected,
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.monthViewNotifier,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;
  final ValueNotifier<bool>? monthViewNotifier;

  @override
  State<OrgaWeekMonthCalendar> createState() => _OrgaWeekMonthCalendarState();
}

class _OrgaWeekMonthCalendarState extends State<OrgaWeekMonthCalendar> {
  static const Duration _kTransition = Duration(milliseconds: 500);

  late OrgaCalendarController _controller;
  VoidCallback? _externalViewListener;
  late DateTime _lastReportedMonth;
  late DateTime _lastReportedSelected;
  bool _didAlignWeekPage = false;

  @override
  void initState() {
    super.initState();
    _controller = OrgaCalendarController(
      initialSelected: widget.selected,
      initialMonthView: widget.monthViewNotifier?.value ?? false,
    )..addListener(_onControllerChanged);
    _lastReportedMonth = _controller.displayedMonth;
    _lastReportedSelected = _controller.selected;
    _attachExternalViewNotifier(widget.monthViewNotifier);
  }

  @override
  void didUpdateWidget(OrgaWeekMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = OrgaCalendarDateUtils.dateOnly(widget.selected);
    if (next != _controller.selected) {
      _controller.setSelected(next);
      if (!_controller.monthView) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.jumpToSelectedWeek();
        });
      }
    }

    if (oldWidget.monthViewNotifier != widget.monthViewNotifier) {
      if (_externalViewListener != null) {
        oldWidget.monthViewNotifier?.removeListener(_externalViewListener!);
      }
      _externalViewListener = null;
      _attachExternalViewNotifier(widget.monthViewNotifier);
    }
  }

  @override
  void dispose() {
    if (_externalViewListener != null) {
      widget.monthViewNotifier?.removeListener(_externalViewListener!);
    }
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    print('onControllerChanged');
    if (_controller.selected != _lastReportedSelected) {
      _lastReportedSelected = _controller.selected;
      widget.onDateChanged(_controller.selected);
    }
    if (_controller.displayedMonth != _lastReportedMonth) {
      _lastReportedMonth = _controller.displayedMonth;
      widget.onDisplayedMonthChanged?.call(_controller.displayedMonth);
    }
    if (mounted) setState(() {});
  }

  void _attachExternalViewNotifier(ValueNotifier<bool>? notifier) {
    if (notifier == null) return;
    _externalViewListener = () {
      _controller.setMonthView(notifier.value);
    };
    notifier.addListener(_externalViewListener!);
  }

  void _emit(DateTime d) {
    _controller.setSelected(d);
    widget.onDateChanged(_controller.selected);
  }

  @override
  Widget build(BuildContext context) {
    if (!_didAlignWeekPage) {
      _didAlignWeekPage = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.jumpToSelectedWeek();
      });
    }

    final today = DateTime.now();
    final selectedColumn =
        OrgaCalendarDateUtils.weekdayColumnIndex(_controller.selected);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WeekdayHeaderRow(
          highlightedColumnIndex: selectedColumn,
        ),
        ClipRect(
          child: AnimatedSize(
            duration: _kTransition,
            curve: Curves.easeInOutCubicEmphasized,
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder(
              valueListenable: EventService.listenFromHive(), 
              builder: (context, value, _) {
                return _controller.monthView
                  ? OrgaMonthCalendar(
                      selected: _controller.selected,
                      monthPageController: _controller.monthPageController,
                      eventDates: _controller.eventDates, 
                      onSelectDay: (d) {
                        _emit(d);
                        _controller.syncToSelectedMonth(animate: true);
                      },
                      onPageChanged: _controller.onMonthPageChanged,
                      monthForPage: _controller.monthForPage,
                    )
                    : CalendarWeekStrip(
                        today: today,
                        selected: _controller.selected,
                        pageController: _controller.weekPageController,
                        weekDaysForPage: _controller.weekDaysForPage,
                        eventDates: _controller.eventDates,
                        onWeekPageChanged: (i) {
                          final day = _controller.selectedForWeekPage(i);
                          if (day == _controller.selected) return;
                          _emit(day);
                        },
                        onDayTap: _emit,
                      );
                    },
                  )
          ),
        ),
      ],
    );
  }
}
