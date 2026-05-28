import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:orga1/core/habit/entity/habit_with_events.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/habit_card.dart';
import 'component/habit_card_week.dart';
import 'component/quick-log-bottom-sheet.dart';
import 'component/weekly_calendar.dart';
import 'controller/home_controller.dart';
import 'models/home_view_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);
  final HomeController _controller = HomeController();

  final double _appBarHeight = 64.0;
  final double _calendarHeight = 150.0;

  static const Color _iosGroupedBackground = Color(0xFFF2F2F7);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _controller.initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollOffset.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
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
                      sliver: _controller.loadingHabits
                          ? const SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = _controller.habits[index];
                                  final isSelected =
                                      _controller.selectedHabitId ==
                                          item.habit.id;

                                  if (_controller.viewMode == HomeViewMode.week) {
                                    return HabitWeekMatrixCard(
                                      item: item,
                                      targetDate: _controller.focusDate,
                                      onDayToggled: (day) =>
                                          _controller.toggleDay(item, day),
                                    );
                                  }

                                  return GestureDetector(
                                    onTap: () => _controller.selectHabit(item.habit.id),
                                    child: HabitCard(
                                      index: index,
                                      item: item,
                                      targetDate: _controller.focusDate,
                                      isSelected: isSelected,
                                      onActionPressed: () {
                                        _controller.selectHabit(item.habit.id);
                                        _showQuickLogModal(context, item);
                                      },
                                    ),
                                  );
                                },
                                childCount: _controller.habits.length,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: _scrollOffset,
                builder: (context, offset, child) {
                  final shrinkProgress =
                      (offset / _appBarHeight).clamp(0.0, 1.0);
                  final currentAppBarHeight =
                      _appBarHeight * (1 - shrinkProgress);
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Opacity(
                                  opacity: opacity,
                                  child: SizedBox(
                                    height: currentAppBarHeight,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 14),
                                      child: const Center(
                                        child: appBar(title: 'Habit'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(
                                  height: _calendarHeight,
                                  child: InfiniteWeeklyCalendar(
                                    viewMode: _controller.viewMode,
                                    onViewModeChanged: _controller.setViewMode,
                                    focusDate: _controller.focusDate,
                                    onFocusDateChanged: _controller.setFocusDate,
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
      },
    );
  }

  void _showQuickLogModal(BuildContext context, HabitWithEvents item) {
    final quickLogHabit = _controller.habitToQuickLogHabit(item);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogBottomSheet(
        habit: quickLogHabit,
        onEditHabit: _controller.updateHabitFromQuickLog,
        onSave: (updatedValue, notes) async {
          if (notes.isNotEmpty) {
            debugPrint('Attached note to session: $notes');
          }
          await _controller.persistProgress(
            item,
            _controller.focusDate,
            updatedValue,
          );
        },
      ),
    );
  }
}
