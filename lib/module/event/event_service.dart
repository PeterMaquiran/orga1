import 'package:orga1/module/event/repository/calendar_event_repository.dart';
import 'package:orga1/ui/screen/ios/calendar/models/stored_calendar_event.dart';

var calendarEventRepository  = CalendarEventRepository();

class EventService {
  static CalendarEventRepository get repository => calendarEventRepository;
  static listenFromHive() {
    return calendarEventRepository.listenable;
  }

  static List<StoredCalendarEvent> getAll() {
    return repository.getAll();
  }
}