import 'package:flutter/cupertino.dart';

enum CalendarView {
  week,
  month,
}

final ValueNotifier<CalendarView> calendarView =
    ValueNotifier(CalendarView.week);

void showCalendarViewSelector(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: const Text('Calendar View'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            calendarView.value = CalendarView.week;
            Navigator.pop(context);
          },
          child: const Text('Week View'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            calendarView.value = CalendarView.month;
            Navigator.pop(context);
          },
          child: const Text('Month View'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ),
  );
}
