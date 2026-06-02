import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../logic/calendar_event_expander.dart';
import '../logic/create_event_formatters.dart';
import '../models/calendar_day_event_group.dart';
import '../models/calendar_event_list_mode.dart';
import '../models/stored_calendar_event.dart';

class CalendarEventList extends StatefulWidget {
  const CalendarEventList({
    super.key,
    required this.groups,
    required this.loading,
    required this.listMode,
    required this.selectedDay,
    required this.displayedMonth,
    required this.scrollController,
    required this.listTopPadding,
    required this.onEventTap,
  });

  final List<CalendarDayEventGroup> groups;
  final bool loading;
  final CalendarEventListMode listMode;
  final DateTime selectedDay;
  final DateTime displayedMonth;
  final ScrollController scrollController;
  final double listTopPadding;
  final ValueChanged<CalendarEventOccurrence> onEventTap;

  static const double headerHeight = 40;
  static const double tileHeight = 78;

  /// Rough scrollable height of all groups (for a finite [cacheExtent]).
  static double estimatedGroupsHeight(List<CalendarDayEventGroup> groups) {
    var height = 0.0;
    for (final group in groups) {
      height += headerHeight + group.occurrences.length * tileHeight;
    }
    return height;
  }

  @override
  State<CalendarEventList> createState() => CalendarEventListState();
}

class CalendarEventListState extends State<CalendarEventList> {
  CalendarEventListState() {
    print('CalendarEventListState created');
  }
  final Map<DateTime, GlobalKey> _dayHeaderKeys = {};

  bool get _scrollableByDay =>
      widget.listMode == CalendarEventListMode.fromTodayForward;

  GlobalKey _headerKeyFor(DateTime day) {
    final normalized = CalendarEventExpander.dateOnly(day);
    return _dayHeaderKeys.putIfAbsent(normalized, GlobalKey.new);
  }

  /// Scrolls the event list so [day]'s section header sits below the pinned header.
  Future<void> scrollToDay(DateTime day) async {
    if (!_scrollableByDay) return;

    final normalized = CalendarEventExpander.dateOnly(day);
    if (!_hasSection(normalized)) return;

    _jumpToEstimatedDay(normalized);

    for (var attempt = 0; attempt < 4; attempt++) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      if (await _alignDayHeader(normalized)) return;
    }
  }

  bool _hasSection(DateTime day) {
    return widget.groups.any(
      (g) => CalendarEventExpander.dateOnly(g.day) == day,
    );
  }

  void _jumpToEstimatedDay(DateTime day) {
    if (!widget.scrollController.hasClients) return;
    final estimated = _estimatedOffsetForDay(day);
    if (estimated == null || !estimated.isFinite) return;

    final position = widget.scrollController.position;
    final max = position.maxScrollExtent;
    if (!max.isFinite) return;

    widget.scrollController.jumpTo(
      estimated.clamp(position.minScrollExtent, max),
    );
  }

  Future<bool> _alignDayHeader(DateTime day) async {
    final context = _dayHeaderKeys[day]?.currentContext;
    if (context == null || !context.mounted) return false;

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return false;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return false;

    final position = scrollable.position;
    final viewport = RenderAbstractViewport.of(renderObject);
    final revealed = viewport.getOffsetToReveal(renderObject, 0);
    final rawTarget = revealed.offset - widget.listTopPadding;
    if (!rawTarget.isFinite) return false;

    final target = rawTarget.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (!target.isFinite) return false;

    if ((position.pixels - target).abs() < 1) return true;

    await position.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
    return true;
  }

  double? _estimatedOffsetForDay(DateTime day) {
    var offset = widget.listTopPadding;
    for (final group in widget.groups) {
      if (CalendarEventExpander.dateOnly(group.day) == day) {
        return offset;
      }
      offset +=
          CalendarEventList.headerHeight +
          group.occurrences.length * CalendarEventList.tileHeight;
    }
    return null;
  }

  String get _emptyMessage {
    switch (widget.listMode) {
      case CalendarEventListMode.selectedDayOnly:
        return 'No events on ${CreateEventFormatters.formatShortDate(widget.selectedDay)}';
      case CalendarEventListMode.fromTodayForward:
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
        final name = monthNames[widget.displayedMonth.month - 1];
        return 'No events in $name ${widget.displayedMonth.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CupertinoActivityIndicator()),
        ),
      );
    }

    if (widget.groups.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            _emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          var itemIndex = 0;
          for (final group in widget.groups) {
            if (itemIndex == index) {
              return _DaySectionHeader(
                key: _scrollableByDay ? _headerKeyFor(group.day) : null,
                day: group.day,
              );
            }
            itemIndex++;

            for (var i = 0; i < group.occurrences.length; i++) {
              if (itemIndex == index) {
                final occurrence = group.occurrences[i];
                return _CalendarEventTile(
                  occurrence: occurrence,
                  onTap: () => widget.onEventTap(occurrence),
                );
              }
              itemIndex++;
            }
          }
          return null;
        },
        childCount: widget.groups.fold<int>(
          0,
          (sum, group) => sum + 1 + group.occurrences.length,
        ),
      ),
    );
  }
}

class _DaySectionHeader extends StatelessWidget {
  const _DaySectionHeader({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalized = DateTime(day.year, day.month, day.day);
    final label = normalized == today
        ? 'Today'
        : CreateEventFormatters.formatShortDate(day);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: CupertinoColors.label.resolveFrom(context),
        ),
      ),
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({
    required this.occurrence,
    required this.onTap,
  });

  final CalendarEventOccurrence occurrence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final event = occurrence.event;
    final location = event.location.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 44,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CreateEventFormatters.formatOccurrenceTime(occurrence),
                        style: TextStyle(
                          fontSize: 14,
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2),
                  child: Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
