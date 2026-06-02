enum CalendarEventListMode {
  selectedDayOnly,
  fromTodayForward,
}

extension CalendarEventListModeLabel on CalendarEventListMode {
  String get menuLabel {
    switch (this) {
      case CalendarEventListMode.selectedDayOnly:
        return 'Selected Day Only';
      case CalendarEventListMode.fromTodayForward:
        return 'This Month';
    }
  }
}
