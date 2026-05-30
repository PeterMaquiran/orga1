import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/shared/menu-achor.dart';

import '../../../../shared/appbar.dart';
import '../../../../shared/navigationBar.dart';
import '../component/create-event.dart';
import '../logic/calendar_screen_controller.dart';
import '../models/calendar_view_mode.dart';
import '../widgets/calendar_event_list.dart';
import '../widgets/orga_week_month_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarScreenController _controller;
  late ValueNotifier<bool> _monthViewNotifier;
  late final ScrollController _scrollController;
  late final ValueNotifier<double> _scrollOffset;

  @override
  void initState() {
    super.initState();
    _controller = CalendarScreenController();
    _controller.addListener(_onControllerChanged);
    _scrollController = ScrollController();
    _scrollOffset = ValueNotifier(0);

    calendarView.value = CalendarView.month;
    _monthViewNotifier = ValueNotifier(calendarView.value == CalendarView.month);

    calendarView.addListener(() {
      _monthViewNotifier.value = calendarView.value == CalendarView.month;
    });

    _scrollController.addListener(_onScroll);
    _controller.initialize();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _scrollOffset.dispose();
    _monthViewNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    _scrollOffset.value = offset;

    if (offset > 0 && calendarView.value == CalendarView.month) {
      calendarView.value = CalendarView.week;
    }

    if (offset <= 0 && calendarView.value == CalendarView.week) {
      calendarView.value = CalendarView.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final today = DateTime.now();
    final todayDay = DateTime(today.year, today.month, today.day);
    const monthNames = [
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

    const double appBarHeight = 64.0;
    const double calendarHeight = 150.0;
    final selected = _controller.selected;
    final displayedMonth = _controller.displayedMonth;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
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
              return Positioned.fill(
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: safeTop +
                            appBarHeight +
                            calendarHeight +
                            listTopInset,
                        bottom: 120,
                        left: 16,
                        right: 16,
                      ),
                      sliver: CalendarEventList(
                        occurrences: _controller.selectedDayOccurrences,
                        loading: _controller.loading,
                        selectedDay: selected,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              final shrinkProgress = (offset / appBarHeight).clamp(0.0, 1.0);
              final currentAppBarHeight = appBarHeight * (1 - shrinkProgress);
              final opacity = (1 - shrinkProgress).clamp(0.0, 1.0);

              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
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
                            child: Opacity(
                              opacity: opacity,
                              child: SizedBox(
                                height: currentAppBarHeight,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: const Center(
                                    child: appBar(title: 'Calendar'),
                                  ),
                                ),
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
                                    StatsMenuButton(
                                      items: [
                                        StatsMenuItem(
                                          value: 'null',
                                          label: 'Today',
                                          onPressed: () {
                                            _controller.setSelected(todayDay);
                                          },
                                        ),
                                        StatsMenuItem(
                                          value: 'null1',
                                          label: 'Week',
                                          onPressed: () {
                                            calendarView.value = CalendarView.week;
                                          },
                                        ),
                                        StatsMenuItem(
                                          value: 'null2',
                                          label: 'Month',
                                          onPressed: () {
                                            calendarView.value = CalendarView.month;
                                          },
                                        ),
                                      ],
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: _monthViewNotifier,
                                      builder: (context, isMonthView, _) {
                                        final String title = isMonthView
                                            ? '${monthNames[displayedMonth.month - 1]} ${displayedMonth.year}'
                                            : (selected == todayDay
                                                ? 'Today'
                                                : (() {
                                                    final yearStr =
                                                        selected.year != today.year
                                                            ? ', ${selected.year}'
                                                            : '';
                                                    const shortMonths = [
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
                                                    return '${shortMonths[selected.month - 1]} ${selected.day}$yearStr';
                                                  })());
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
                                    ),
                                    Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemBackground
                                            .resolveFrom(context),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: const Color(0xFF3C3C43)
                                              .withValues(alpha: 0.12),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.06),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  _showEventHabitModal(context),
                                              child: Icon(
                                                CupertinoIcons.add,
                                                size: 22,
                                                color: CupertinoColors
                                                    .secondaryLabel
                                                    .resolveFrom(context),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          SizedBox(
                                            width: 44,
                                            height: 44,
                                            child: CupertinoButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                showCalendarViewSelector(context);
                                              },
                                              child: Icon(
                                                CupertinoIcons.slider_horizontal_3,
                                                size: 22,
                                                color: CupertinoColors
                                                    .secondaryLabel
                                                    .resolveFrom(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Material(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  shadowColor: Colors.black26,
                                  borderRadius: BorderRadius.circular(16),
                                  clipBehavior: Clip.antiAlias,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 19),
                                    child: OrgaWeekMonthCalendar(
                                      monthViewNotifier: _monthViewNotifier,
                                      selected: selected,
                                      eventDates: _controller.eventDates,
                                      onDisplayedMonthChanged: (month) {
                                        _controller.setDisplayedMonth(month);
                                      },
                                      onDateChanged: (date) {
                                        _controller.setSelected(date);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color:
                                const Color(0xFF3C3C43).withValues(alpha: 0.29),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(),
    );
  }

  void _showEventHabitModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: CreateEventBottomSheet(
            onSaved: _controller.refresh,
          ),
        );
      },
    );
  }
}
