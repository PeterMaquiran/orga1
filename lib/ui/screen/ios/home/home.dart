import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../shared/appbar.dart';
import '../../../shared/navigationBar.dart';
import 'component/habit_list.dart'; // Contains HabitCard definition
import 'component/quick-log-bottom-sheet.dart';
import 'component/weekly_calendar.dart'; // Contains InfiniteWeeklyCalendar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollOffset = ValueNotifier(0);

  // Configuration Constants (large title needs a bit more vertical room)
  final double _appBarHeight = 64.0;
  final double _calendarHeight = 150.0;

  static const Color _iosGroupedBackground = Color(0xFFF2F2F7);

  // 1. STATEFUL PROPERTIES (Moved out of build block to preserve state changes)
// Update your _myHabits dictionary models block on the Parent State to look like this:
  final List<Map<String, dynamic>> _myHabits = [
    {
      'id': '1',
      'title': 'Drink Clean Water',
      'emoji': '💧',
      'color': const Color(0xFF007AFF),
      'goalType': 'liters',
      'unit': 'L',
      'currentValue': 1.5,
      'targetValue': 3.0,
      'timeText': '07:30 AM'
    },
    {
      'id': '2',
      'title': 'Morning Meditation',
      'emoji': '🧘',
      'color': const Color(0xFF5856D6),
      'goalType': 'time',
      'unit': 'min',
      'currentValue': 20.0,
      'targetValue': 20.0,
      'timeText': '08:00 AM'
    },
    {
      'id': '4',
      'title': 'Take Core Vitamins',
      'emoji': '💊',
      'color': const Color(0xFF34C759),
      'goalType': 'checkmark',
      'unit': '',
      'currentValue': 0.0, // 0 means false, 1.0 means checked
      'targetValue': 1.0,
      'timeText': '07:00 AM'
    },
    {
      'id': '1',
      'title': 'Drink Clean Water',
      'emoji': '💧',
      'color': const Color(0xFF007AFF),
      'goalType': 'liters',
      'unit': 'L',
      'currentValue': 1.5,
      'targetValue': 3.0,
      'timeText': '07:30 AM'
    },
    {
      'id': '2',
      'title': 'Morning Meditation',
      'emoji': '🧘',
      'color': const Color(0xFF5856D6),
      'goalType': 'time',
      'unit': 'min',
      'currentValue': 20.0,
      'targetValue': 20.0,
      'timeText': '08:00 AM'
    },
    {
      'id': '4',
      'title': 'Take Core Vitamins',
      'emoji': '💊',
      'color': const Color(0xFF34C759),
      'goalType': 'checkmark',
      'unit': '',
      'currentValue': 0.0, // 0 means false, 1.0 means checked
      'targetValue': 1.0,
      'timeText': '07:00 AM'
    },
    {
      'id': '1',
      'title': 'Drink Clean Water',
      'emoji': '💧',
      'color': const Color(0xFF007AFF),
      'goalType': 'liters',
      'unit': 'L',
      'currentValue': 1.5,
      'targetValue': 3.0,
      'timeText': '07:30 AM'
    },
    {
      'id': '2',
      'title': 'Morning Meditation',
      'emoji': '🧘',
      'color': const Color(0xFF5856D6),
      'goalType': 'time',
      'unit': 'min',
      'currentValue': 20.0,
      'targetValue': 20.0,
      'timeText': '08:00 AM'
    },
    {
      'id': '4',
      'title': 'Take Core Vitamins',
      'emoji': '💊',
      'color': const Color(0xFF34C759),
      'goalType': 'checkmark',
      'unit': '',
      'currentValue': 0.0, // 0 means false, 1.0 means checked
      'targetValue': 1.0,
      'timeText': '07:00 AM'
    },
    {
      'id': '1',
      'title': 'Drink Clean Water',
      'emoji': '💧',
      'color': const Color(0xFF007AFF),
      'goalType': 'liters',
      'unit': 'L',
      'currentValue': 1.5,
      'targetValue': 3.0,
      'timeText': '07:30 AM'
    },
    {
      'id': '2',
      'title': 'Morning Meditation',
      'emoji': '🧘',
      'color': const Color(0xFF5856D6),
      'goalType': 'time',
      'unit': 'min',
      'currentValue': 20.0,
      'targetValue': 20.0,
      'timeText': '08:00 AM'
    },
    {
      'id': '4',
      'title': 'Take Core Vitamins',
      'emoji': '💊',
      'color': const Color(0xFF34C759),
      'goalType': 'checkmark',
      'unit': '',
      'currentValue': 0.0, // 0 means false, 1.0 means checked
      'targetValue': 1.0,
      'timeText': '07:00 AM'
    },
  ];
  // Selected State Container
  late Map<String, dynamic> _selectedHabit;

  @override
  void initState() {
    super.initState();
    // Initialize with the first item in our list as fallback
    _selectedHabit = _myHabits[0];

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });
  }

  // 2. STATE INTERACTIVITY CONTROLLER METHOD
  void _changeActiveHabit(Map<String, dynamic> habit) {
    setState(() {
      _selectedHabit = habit;
    });
    debugPrint("Swapped active log target to: ${habit['title']}");
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
      // CRITICAL: extendBody allows the list to scroll behind the floating nav bar
      extendBody: true,

      // We keep the Stack approach to handle the background and sticky header
      body: Stack(
        children: [
          /// 1. iOS system grouped background (Settings / Reminders style)
          Positioned.fill(
            child: ColoredBox(color: _iosGroupedBackground),
          ),

          /// 2. THE SCROLLABLE CONTENT WITH INTEGRATED LIST DATA
          Positioned.fill(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: safeTop + _appBarHeight + _calendarHeight + 10,
                    bottom: 120, // Extra bottom padding so items aren't hidden by NavBar
                    left: 16,
                    right: 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final habit = _myHabits[index];
                        final bool isSelected = _selectedHabit['id'] == habit['id'];

                        return GestureDetector(
                          onTap: () {
                            _changeActiveHabit(habit);
                            // 1. Tapping the card body opens the sheet if it's an incremental habit
                            //if (habit['goalType'] != 'checkmark') {
                              //_showQuickLogModal(context, habit);
                            //}
                          },
                          child: HabitCard(
                            index: index,
                            title: habit['title'],
                            emoji: habit['emoji'],
                            goalType: habit['goalType'],
                            currentValue: habit['currentValue'],
                            targetValue: habit['targetValue'],
                            unit: habit['unit'] ?? '',
                            timeText: habit['timeText'] ?? '08:00 AM',
                            color: habit['color'],
                            isSelected: isSelected,
                            onActionPressed: () {
                              // 2. Trailing button execution routing
                              _showQuickLogModal(context, habit);
                            },
                          ),
                        );
                      },
                      childCount: _myHabits.length,
                    ),
                  )
                ),
              ],
            ),
          ),

          /// 3. THE DYNAMIC HEADER
          ValueListenableBuilder<double>(
            valueListenable: _scrollOffset,
            builder: (context, offset, child) {
              double shrinkProgress = (offset / _appBarHeight).clamp(0.0, 1.0);
              double currentAppBarHeight = _appBarHeight * (1 - shrinkProgress);
              double opacity = (1 - shrinkProgress).clamp(0.0, 1.0);

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
                                  child: const Center(child: appBar(title: "Habit")),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              height: _calendarHeight,
                              child: const InfiniteWeeklyCalendar(),
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
                ),
              );
            },
          ),
        ],
      ),

      /// 4. THE FLOATING NAVIGATION BAR
      bottomNavigationBar: const FloatingNavBar(),
    );
  }


  void _showQuickLogModal(BuildContext context, Map<String, dynamic> habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogBottomSheet(
        habit: habit,
        onSave: (updatedValue, notes) {
          setState(() {
            habit['currentValue'] = updatedValue;
            if (notes.isNotEmpty) {
              debugPrint("Attached Note to session: $notes");
            }
          });
        },
      ),
    );
  }
}