import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/shared/menu-achor.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/create-event.dart';
import 'component/event-details-bottom-sheet.dart';
import 'logic/calendar_screen_controller.dart';
import 'models/calendar_event_list_mode.dart';
import 'models/calendar_menu_selection.dart';
import 'models/calendar_view_mode.dart';
import 'widgets/calendar_event_list.dart';
import 'widgets/orga_week_month_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarScreenController _controller;
  late ValueNotifier<bool> _monthViewNotifier;
  late final ScrollController _scrollController;
  final GlobalKey<CalendarEventListState> _eventListKey =
      GlobalKey<CalendarEventListState>();

  @override
  void initState() {
    super.initState();
    _controller = CalendarScreenController();
    _scrollController = ScrollController();

    calendarView.value = CalendarView.month;
    _monthViewNotifier = ValueNotifier(calendarView.value == CalendarView.month);
    _syncCalendarViewMode();

    calendarView.addListener(_syncCalendarViewMode);
    _scrollController.addListener(_onScroll);
    _controller.initialize();
    
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;

    if (offset > 0 && calendarView.value == CalendarView.month) {
      if(calendarView.value != CalendarView.week) {
        calendarView.value = CalendarView.week;
      }
    }

    if (offset <= 0 && calendarView.value == CalendarView.week) {
      if(calendarView.value != CalendarView.month) {
        calendarView.value = CalendarView.month;
      }
    }
  }

  void _onCalendarDateChanged(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    _controller.setSelected(normalized);
    _scrollEventListToDay(normalized);
  }

  /// Enough cache to build off-screen day headers without [double.infinity]
  /// (which breaks viewport semantics).
  double _listCacheExtent(CalendarScreenController controller) {
    if (controller.listMode != CalendarEventListMode.fromTodayForward) {
      return 400;
    }
    final contentHeight =
        CalendarEventList.estimatedGroupsHeight(controller.eventGroups);
    return (contentHeight + 600).clamp(400.0, 8000.0);
  }

  void _scrollEventListToDay(DateTime day) {
    if (_controller.listMode != CalendarEventListMode.fromTodayForward) {
      return;
    }

    Future<void> attempt() async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      await _eventListKey.currentState?.scrollToDay(day);
    }

    attempt();
  }

  void _syncCalendarViewMode() {
    final isMonth = calendarView.value == CalendarView.month;
    if (_monthViewNotifier.value != isMonth) {
      _monthViewNotifier.value = isMonth;
    }
    _controller.setMonthView(isMonth);
  }

  List<StatsMenuItem<void>> _calendarMenuItems() {
    return [
      StatsMenuItem<void>(
        value: null,
        label: 'Week View',
        selectionGroup: CalendarMenuSelectionGroup.view,
        selectionValue: CalendarView.week,
        onPressed: () => calendarView.value = CalendarView.week,
      ),
      StatsMenuItem<void>(
        value: null,
        label: 'Month View',
        selectionGroup: CalendarMenuSelectionGroup.view,
        selectionValue: CalendarView.month,
        onPressed: () => calendarView.value = CalendarView.month,
      ),
      const StatsMenuItem<void>.divider(),
      StatsMenuItem<void>(
        value: null,
        label: CalendarEventListMode.selectedDayOnly.menuLabel,
        selectionGroup: CalendarMenuSelectionGroup.listMode,
        selectionValue: CalendarEventListMode.selectedDayOnly,
        onPressed: () => _controller.setListMode(
          CalendarEventListMode.selectedDayOnly,
        ),
      ),
      StatsMenuItem<void>(
        value: null,
        label: CalendarEventListMode.fromTodayForward.menuLabel,
        selectionGroup: CalendarMenuSelectionGroup.listMode,
        selectionValue: CalendarEventListMode.fromTodayForward,
        onPressed: () => _controller.setListMode(
          CalendarEventListMode.fromTodayForward,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    calendarView.removeListener(_syncCalendarViewMode);
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    _monthViewNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    const appBarHeight = 64.0;
    const calendarHeight = 150.0;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8F9FA),
                    Color(0xFFE9ECEF),
                    Color(0xFFDEE2E6),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _monthViewNotifier,
            builder: (context, isMonthView, _) {
              final listTopInset = isMonthView ? 188.0 : 10.0;
              final listTopPadding = safeTop +
                  appBarHeight +
                  calendarHeight +
                  listTopInset;
              return Positioned.fill(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    print('CalendarEventListState createdfasdasfads');
                    return CustomScrollView(
                      controller: _scrollController,
                      cacheExtent: _listCacheExtent(_controller),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.only(
                            top: listTopPadding,
                            bottom: 120,
                            left: 16,
                            right: 16,
                          ),
                          sliver: CalendarEventList(
                            key: _eventListKey,
                            groups: _controller.eventGroups,
                            loading: _controller.loading,
                            listMode: _controller.listMode,
                            selectedDay: _controller.selected,
                            displayedMonth: _controller.displayedMonth,
                            scrollController: _scrollController,
                            listTopPadding: listTopPadding,
                            onEventTap: (occurrence) {
                              EventDetailsBottomSheet.open(
                                context,
                                occurrence: occurrence,
                                onChanged: _controller.refresh,
                                onDelete: _controller.deleteEvent,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: _CalendarPinnedHeader(
                safeTop: safeTop,
                appBarHeight: appBarHeight,
                controller: _controller,
                monthViewNotifier: _monthViewNotifier,
                menuItems: _calendarMenuItems,
                onDateChanged: _onCalendarDateChanged,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }
}

class _CalendarPinnedHeader extends StatelessWidget {
  const _CalendarPinnedHeader({
    required this.safeTop,
    required this.appBarHeight,
    required this.controller,
    required this.monthViewNotifier,
    required this.menuItems,
    required this.onDateChanged,
  });

  final double safeTop;
  final double appBarHeight;
  final CalendarScreenController controller;
  final ValueNotifier<bool> monthViewNotifier;
  final List<StatsMenuItem<void>> Function() menuItems;
  final ValueChanged<DateTime> onDateChanged;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withValues(alpha: 0.72),
          padding: EdgeInsets.only(top: safeTop),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: appBarHeight,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Center(child: appBar(title: 'Calendar')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<CalendarView>(
                        valueListenable: calendarView,
                        builder: (context, view, _) {
                          return ListenableBuilder(
                            listenable: controller,
                            builder: (context, _) {
                              return StatsMenuButton<void>(
                                icon: CupertinoIcons.ellipsis_circle,
                                selectedByGroup: calendarMenuSelectedByGroup(
                                  view: view,
                                  listMode: controller.listMode,
                                ),
                                items: menuItems(),
                              );
                            },
                          );
                        },
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: monthViewNotifier,
                        builder: (context, isMonthView, _) {
                          return ListenableBuilder(
                            listenable: controller,
                            builder: (context, _) {
                              final selected = controller.selected;
                              final displayedMonth = controller.displayedMonth;
                              final title = isMonthView
                                  ? '${_monthNames[displayedMonth.month - 1]} ${displayedMonth.year}'
                                  : selected == todayDay
                                      ? 'Today'
                                      : _weekTitle(selected, today);
                              return Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  letterSpacing: -0.41,
                                  color: CupertinoColors.label
                                      .resolveFrom(context),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF3C3C43)
                                  .withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              CreateEventBottomSheet.open(
                                context,
                                onSaved: controller.refresh,
                              );
                            },
                            child: Icon(
                              CupertinoIcons.add,
                              size: 22,
                              color: CupertinoColors.secondaryLabel
                                  .resolveFrom(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) {
                      return RepaintBoundary(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 19),
                          child: OrgaWeekMonthCalendar(
                            monthViewNotifier: monthViewNotifier,
                            selected: controller.selected,
                            eventDates: controller.eventDates,
                            onDisplayedMonthChanged: controller.setDisplayedMonth,
                            onDateChanged: onDateChanged,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: const Color(0xFF3C3C43).withValues(alpha: 0.29),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _weekTitle(DateTime selected, DateTime today) {
    final yearStr =
        selected.year != today.year ? ', ${selected.year}' : '';
    return '${_shortMonths[selected.month - 1]} ${selected.day}$yearStr';
  }
}
