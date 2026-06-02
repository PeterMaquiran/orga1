import 'calendar_event_list_mode.dart';
import 'calendar_view_mode.dart';

/// Keys for [StatsMenuButton.selectedByGroup] on the calendar screen menu.
abstract final class CalendarMenuSelectionGroup {
  static const view = 'calendarView';
  static const listMode = 'eventListMode';
}

Map<Object, Object> calendarMenuSelectedByGroup({
  required CalendarView view,
  required CalendarEventListMode listMode,
}) {
  return {
    CalendarMenuSelectionGroup.view: view,
    CalendarMenuSelectionGroup.listMode: listMode,
  };
}
