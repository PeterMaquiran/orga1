import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orga1/ui/screen/ios/calendar/screens/calendar_screen.dart';
import 'package:orga1/ui/shared/menu-achor.dart';
import '../../calendar/logic/calendar_date_utils.dart';
import '../../calendar/widgets/weekday_header_row.dart';
import 'create-habit.dart';

class InfiniteWeeklyCalendar extends StatelessWidget {
  const InfiniteWeeklyCalendar({super.key});

  static const int _virtualCenter = 10000;

  List<DateTime> _getWeekForIndex(int index, DateTime today) {
    final int weekOffset = index - _virtualCenter;
    final DateTime firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final DateTime startOfTargetWeek = firstDayOfWeek.add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => startOfTargetWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final PageController controller = PageController(initialPage: _virtualCenter);
    final ValueNotifier<DateTime> focusedDate = ValueNotifier(_getWeekForIndex(_virtualCenter, today).last);
    final Color iconColor = CupertinoColors.secondaryLabel.resolveFrom(context);
    final todayColumn = OrgaCalendarDateUtils.weekdayColumnIndex(today);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatsMenuButton(
                selectedValue: "",
                onSelected: (value) {
                  print(value);
                },
                icon: CupertinoIcons.square_grid_2x2,
                items: [
                  StatsMenuItem(
                    value: "null1",
                    label: 'Today',
                    onPressed: () => const {},
                  ),
                  StatsMenuItem(
                    value: "null2",
                    label: 'Week',
                    onPressed: () {},
                  ),
                  StatsMenuItem(
                    value: "null3",
                    label: 'Month',
                    onPressed: () {},
                  ),
                ],
              ),
              ValueListenableBuilder<DateTime>(
                valueListenable: focusedDate,
                builder: (context, date, _) {
                  final String yearStr = date.year != today.year ? ', ${date.year}' : '';
                  final String month = [
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
                  ][date.month - 1];
                  return Text(
                    '$month ${date.day}$yearStr',
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
                        onPressed: () => _showCreateHabitModal(context),
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
        WeekdayHeaderRow(
          highlightedColumnIndex: todayColumn,
          topPadding: 0,
          letterSpacing: 0.06,
        ),
        SizedBox(
          height: 35,
          child: PageView.builder(
            controller: controller,
            onPageChanged: (i) => focusedDate.value = _getWeekForIndex(i, today).last,
            itemBuilder: (context, index) {
              final week = _getWeekForIndex(index, today);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: week.map((date) {
                  final isToday =
                      date.day == today.day && date.month == today.month && date.year == today.year;
                  return _buildDayCard(context, date, isToday);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(BuildContext context, DateTime date, bool isToday) {
    final active = CupertinoColors.activeBlue.resolveFrom(context);
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF3C3C43).withValues(alpha: 0.12),
          width: 1,
        ),
        color: isToday
            ? active.withValues(alpha: 0.05)
            : CupertinoColors.systemBackground.resolveFrom(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.08,
              color: isToday ? active : labelColor,
            ),
          ),
        ],
      ),
    );
  }


  // Premium iOS Bottom Sheet Modal Invocation
  void _showCreateHabitModal(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true, // <-- CRITICAL: Layers modal cleanly over navigation text layers!
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          clipBehavior: Clip.antiAlias,
          child: const CreateHabitScreen(),
        );
      },
    );
  }
}


