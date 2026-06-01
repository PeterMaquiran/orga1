import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/shared/menu-achor.dart';

import '../../calendar/logic/calendar_date_utils.dart';
import 'package:orga1/ui/screen/ios/home/models/habit_form_input.dart';
import 'package:orga1/ui/screen/ios/home/models/home_view_mode.dart';
import 'create-habit.dart';

class InfiniteWeeklyCalendar extends StatefulWidget {
  const InfiniteWeeklyCalendar({
    super.key,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.focusDate,
    required this.onFocusDateChanged,
    this.onSaveHabit,
    this.dayProgressRatio,
  });

  final HomeViewMode viewMode;
  final ValueChanged<HomeViewMode> onViewModeChanged;
  final DateTime focusDate;
  final ValueChanged<DateTime> onFocusDateChanged;
  final Future<void> Function(HabitFormInput input)? onSaveHabit;
  /// Returns `null` when no progress ring should be shown for that day.
  final double? Function(DateTime day)? dayProgressRatio;

  @override
  State<InfiniteWeeklyCalendar> createState() => InfiniteWeeklyCalendarState();
}

class InfiniteWeeklyCalendarState extends State<InfiniteWeeklyCalendar> {
  static const int _virtualCenter = 10000;

  late final PageController _pageController;
  late final ValueNotifier<DateTime> _headerDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _virtualCenter);
    _headerDate = ValueNotifier(widget.focusDate);
  }

  bool get _isWeekView => widget.viewMode == HomeViewMode.week;

  @override
  void didUpdateWidget(InfiniteWeeklyCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameDay(oldWidget.focusDate, widget.focusDate)) {
      _headerDate.value = widget.focusDate;
    }
    if (oldWidget.viewMode != widget.viewMode && _isWeekView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncWeekViewFocusToAnchor();
      });
    }
  }

  void _syncWeekViewFocusToAnchor() {
    if (!_isWeekView || !_pageController.hasClients) return;
    final today = DateTime.now();
    final index = _pageController.page?.round() ?? _virtualCenter;
    final anchor = _getRollingWindowForIndex(index, today).last;
    if (_sameDay(anchor, widget.focusDate)) {
      _headerDate.value = anchor;
      return;
    }
    _headerDate.value = anchor;
    widget.onFocusDateChanged(anchor);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _headerDate.dispose();
    super.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Rolling window: 6 days of history on the left, anchor day on the right.
  List<DateTime> _getRollingWindowForIndex(int index, DateTime today) {
    final todayNorm = _normalize(today);
    final pageOffset = index - _virtualCenter;
    var anchor = todayNorm.add(Duration(days: pageOffset * 7));
    if (anchor.isAfter(todayNorm)) {
      anchor = todayNorm;
    }
    final start = anchor.subtract(const Duration(days: 6));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  /// [direction] `1` = older week (swipe left), `-1` = newer week (swipe right).
  void shiftWeek(int direction) {
    if (!_pageController.hasClients || direction == 0) return;

    final current =
        _pageController.page?.round() ?? _virtualCenter;
    final target = current - direction;
    if (target > _virtualCenter) return;

    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onWeekPageChanged(int index, DateTime today) {
    if (index > _virtualCenter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_virtualCenter);
        }
      });
      return;
    }

    final window = _getRollingWindowForIndex(index, today);
    final anchor = window.last;
    // Week view: anchor is always the rightmost day so every cell keeps progress data in range.
    final focus = _isWeekView
        ? anchor
        : (window.any((d) => _sameDay(d, widget.focusDate))
            ? widget.focusDate
            : anchor);
    _headerDate.value = focus;
    if (!_sameDay(focus, widget.focusDate)) {
      widget.onFocusDateChanged(focus);
    }
  }

  Widget _buildRollingWeekdayHeader(
    BuildContext context,
    List<DateTime> days,
    DateTime todayDay,
  ) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final tertiary = CupertinoColors.tertiaryLabel.resolveFrom(context);
    const labels = OrgaCalendarDateUtils.weekdayLabels;

    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((date) {
          final isToday = _sameDay(date, todayDay);
          return SizedBox(
            width: OrgaCalendarDateUtils.monthGridRowExtent,
            child: Text(
              labels[date.weekday - 1],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.06,
                color: isToday ? active : tertiary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDay = _normalize(today);
    final iconColor = CupertinoColors.secondaryLabel.resolveFrom(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatsMenuButton<HomeViewMode>(
                selectedValue: widget.viewMode,
                onSelected: widget.onViewModeChanged,
                icon: CupertinoIcons.square_grid_2x2,
                items: [
                  StatsMenuItem(
                    value: HomeViewMode.day,
                    label: HomeViewMode.day.menuLabel,
                  ),
                  StatsMenuItem(
                    value: HomeViewMode.week,
                    label: HomeViewMode.week.menuLabel,
                  ),
                ],
              ),
              ValueListenableBuilder<DateTime>(
                valueListenable: _headerDate,
                builder: (context, date, _) {
                  final yearStr =
                      date.year != today.year ? ', ${date.year}' : '';
                  const months = [
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
                  final month = months[date.month - 1];
                  final label = _sameDay(date, todayDay)
                      ? 'Today'
                      : '$month ${date.day}$yearStr';
                  return Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      letterSpacing: -0.41,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                  );
                },
              ),
              Container(
                width: 100,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
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
                        onPressed: () {
                          CreateHabitScreen.open(
                            context,
                            onSaveHabit: widget.onSaveHabit,
                          );
                        },
                        child: Icon(
                          CupertinoIcons.add,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 22,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 79,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => _onWeekPageChanged(i, today),
            itemBuilder: (context, index) {
              final window = _getRollingWindowForIndex(index, today);
              return Column(
                children: [
                  _buildRollingWeekdayHeader(context, window, todayDay),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: window.map((date) {
                      final anchor = window.last;
                      final isToday = _sameDay(date, todayDay);
                      final isSelected = _isWeekView
                          ? _sameDay(date, anchor)
                          : _sameDay(date, widget.focusDate);
                      return _buildDayCard(
                        context,
                        date,
                        isToday: isToday,
                        isSelected: isSelected,
                        progressRatio: widget.dayProgressRatio?.call(date),
                        allowSelection: !_isWeekView,
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DateTime date, {
    required bool isToday,
    required bool isSelected,
    double? progressRatio,
    bool allowSelection = true,
  }) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);
    final isWeekView = widget.viewMode == HomeViewMode.week;
    final double? effectiveRatio =
        isWeekView ? (progressRatio ?? 0.0) : progressRatio;
    final showProgress = effectiveRatio != null;
    final ratio = effectiveRatio ?? 0.0;
    final isComplete = showProgress && ratio >= 1.0;

    return GestureDetector(
      onTap: allowSelection
          ? () {
              final normalized = _normalize(date);
              _headerDate.value = normalized;
              widget.onFocusDateChanged(normalized);
            }
          : null,
      child: SizedBox(
        width: 35,
        height: 35,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showProgress)
              SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(
                  value: ratio.clamp(0.0, 1.0),
                  strokeWidth: 2.5,
                  backgroundColor: const Color(0xFF3C3C43).withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation(
                    isComplete ? const Color(0xFF34C759) : active,
                  ),
                ),
              ),
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: showProgress
                    ? null
                    : Border.all(
                        color: isSelected
                            ? active
                            : const Color(0xFF3C3C43).withValues(alpha: 0.12),
                        width: isSelected ? 1.5 : 1,
                      ),
                color: isToday
                    ? active.withValues(alpha: 0.05)
                    : CupertinoColors.systemBackground.resolveFrom(context),
              ),
              alignment: Alignment.center,
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.08,
                  color: isToday || isSelected
                      ? active
                      : isComplete
                          ? const Color(0xFF34C759)
                          : labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
