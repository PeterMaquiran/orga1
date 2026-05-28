import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orga1/core/habit/entity/habit.dart';
import 'package:orga1/core/habit/entity/habit_event.dart';
import 'package:orga1/core/habit/entity/habit_with_events.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/habit_card.dart';
import 'component/habit_card_week.dart';
import 'component/quick-log-bottom-sheet.dart';
import 'component/weekly_calendar.dart';
import 'models/home_view_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  final double _appBarHeight = 64.0;
  final double _calendarHeight = 150.0;

  static const Color _iosGroupedBackground = Color(0xFFF2F2F7);

  HomeViewMode _viewMode = HomeViewMode.day;
  late DateTime _focusDate;
  List<HabitWithEvents> _habits = [];
  String? _selectedHabitId;
  bool _loadingHabits = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusDate = DateTime(now.year, now.month, now.day);

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _loadHabits();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  ({DateTime start, DateTime end}) _eventRangeForMode() {
    final focus = _normalizeDate(_focusDate);
    if (_viewMode == HomeViewMode.week) {
      final start = focus.subtract(const Duration(days: 6));
      return (
        start: start,
        end: DateTime(focus.year, focus.month, focus.day, 23, 59, 59),
      );
    }
    return (
      start: focus,
      end: DateTime(focus.year, focus.month, focus.day, 23, 59, 59),
    );
  }

  HabitEvent? _eventFromRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is HabitEvent) return raw;
    if (raw is Map) {
      return HabitEvent.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<void> _loadHabits() async {
    final habitBox = Hive.box('habitsBox');
    final eventBox = Hive.box('habitEventsBox');
    final range = _eventRangeForMode();
    final normalizedStart =
        DateTime(range.start.year, range.start.month, range.start.day);
    final normalizedEnd = range.end;

    final habits = habitBox.values
        .map((raw) => HabitModel.fromMap(Map<String, dynamic>.from(raw as Map)))
        .toList();

    final events = <HabitEvent>[];
    for (final key in eventBox.keys) {
      final event = _eventFromRaw(eventBox.get(key));
      if (event == null) continue;
      final ts = event.timestamp;
      if (!ts.isBefore(normalizedStart) && !ts.isAfter(normalizedEnd)) {
        events.add(event);
      }
    }

    final grouped = <String, List<HabitEvent>>{};
    for (final event in events) {
      grouped.putIfAbsent(event.habitId, () => []).add(event);
    }

    if (!mounted) return;
    setState(() {
      _habits = habits
          .map(
            (habit) => HabitWithEvents(
              habit: habit,
              rangeEvents: grouped[habit.id] ?? [],
            ),
          )
          .toList();
      _selectedHabitId ??= _habits.isNotEmpty ? _habits.first.habit.id : null;
      _loadingHabits = false;
    });
  }

  void _onViewModeChanged(HomeViewMode mode) {
    if (_viewMode == mode) return;
    setState(() => _viewMode = mode);
    _loadHabits();
  }

  void _onFocusDateChanged(DateTime date) {
    final normalized = _normalizeDate(date);
    if (normalized == _focusDate) return;
    setState(() => _focusDate = normalized);
    _loadHabits();
  }

  void _selectHabit(String habitId) {
    setState(() => _selectedHabitId = habitId);
  }

  Map<String, dynamic> _habitToQuickLogMap(HabitWithEvents item) {
    final habit = item.habit;
    return {
      'id': habit.id,
      'title': habit.title,
      'emoji': habit.emoji,
      'color': habit.color,
      'goalType': habit.goalType,
      'unit': habit.unit,
      'currentValue': item.getProgressForDay(_focusDate),
      'targetValue': habit.targetValue,
      'timeText': habit.timeText,
    };
  }

  Future<void> _persistProgress(
    HabitWithEvents item,
    DateTime day,
    double value,
  ) async {
    final eventBox = Hive.box('habitEventsBox');
    final normalized = _normalizeDate(day);

    final keysToRemove = <dynamic>[];
    for (final key in eventBox.keys) {
      final event = _eventFromRaw(eventBox.get(key));
      if (event == null) continue;
      if (event.habitId != item.habit.id) continue;
      final ts = event.timestamp;
      if (ts.year == normalized.year &&
          ts.month == normalized.month &&
          ts.day == normalized.day) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      await eventBox.delete(key);
    }

    if (value > 0) {
      final id = const Uuid().v4();
      await eventBox.put(id, {
        'id': id,
        'habitId': item.habit.id,
        'timestamp': normalized.toIso8601String(),
        'valueLogged': value,
        'note': null,
      });
    }

    await _loadHabits();
  }

  Future<void> _toggleDay(HabitWithEvents item, DateTime day) async {
    final completed = item.isCompletedOnDay(day);
    final nextValue = completed ? 0.0 : item.habit.targetValue;
    await _persistProgress(item, day, nextValue);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: _iosGroupedBackground),
          ),
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: safeTop + _appBarHeight + _calendarHeight + 10,
                    bottom: 120,
                  ),
                  sliver: _loadingHabits
                      ? const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = _habits[index];
                              final isSelected =
                                  _selectedHabitId == item.habit.id;

                              if (_viewMode == HomeViewMode.week) {
                                return HabitWeekMatrixCard(
                                  item: item,
                                  targetDate: _focusDate,
                                  onDayToggled: (day) => _toggleDay(item, day),
                                );
                              }

                              return GestureDetector(
                                onTap: () => _selectHabit(item.habit.id),
                                child: HabitCard(
                                  index: index,
                                  item: item,
                                  targetDate: _focusDate,
                                  isSelected: isSelected,
                                  onActionPressed: () {
                                    _selectHabit(item.habit.id);
                                    _showQuickLogModal(context, item);
                                  },
                                ),
                              );
                            },
                            childCount: _habits.length,
                          ),
                        ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              final shrinkProgress = (offset / _appBarHeight).clamp(0.0, 1.0);
              final currentAppBarHeight = _appBarHeight * (1 - shrinkProgress);
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
                                    child: appBar(title: 'Habit'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: _calendarHeight,
                              child: InfiniteWeeklyCalendar(
                                viewMode: _viewMode,
                                onViewModeChanged: _onViewModeChanged,
                                focusDate: _focusDate,
                                onFocusDateChanged: _onFocusDateChanged,
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: const Color(0xFF3C3C43)
                                .withValues(alpha: 0.29),
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

  void _showQuickLogModal(BuildContext context, HabitWithEvents item) {
    final habitMap = _habitToQuickLogMap(item);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogBottomSheet(
        habit: habitMap,
        onSave: (updatedValue, notes) async {
          if (notes.isNotEmpty) {
            debugPrint('Attached note to session: $notes');
          }
          await _persistProgress(item, _focusDate, updatedValue);
        },
      ),
    );
  }
}
