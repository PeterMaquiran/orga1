class StoredCalendarEvent {
  StoredCalendarEvent({
    required this.id,
    required this.subject,
    this.body,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isRecurring,
    this.recurrence,
    required this.isAllDayEvent,
    this.checklist = const [],
  });

  final String id;
  final String subject;
  final String? body;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final bool isRecurring;
  final StoredEventRecurrence? recurrence;
  final bool isAllDayEvent;
  final List<StoredChecklistItem> checklist;

  factory StoredCalendarEvent.fromMap(Map<String, dynamic> map) {
    final rawRecurrence = map['eventRecurrence'];
    return StoredCalendarEvent(
      id: map['id'] as String,
      subject: map['subject'] as String,
      body: map['body'] as String?,
      location: (map['location'] as String?) ?? '',
      startDate: DateTime.parse(map['startDate'] as String).toLocal(),
      endDate: DateTime.parse(map['endDate'] as String).toLocal(),
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurrence: rawRecurrence is Map
          ? StoredEventRecurrence.fromMap(
              Map<String, dynamic>.from(rawRecurrence),
            )
          : null,
      isAllDayEvent: map['isAllDayEvent'] as bool? ?? false,
      checklist: (map['checklist'] as List?)
              ?.map(
                (item) => StoredChecklistItem.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'body': body,
      'location': location,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isRecurring': isRecurring,
      'isAllDayEvent': isAllDayEvent,
      'hasAttachments': false,
      'isPrivate': false,
      'status': 0,
      if (recurrence != null) 'eventRecurrence': recurrence!.toMap(),
      if (checklist.isNotEmpty)
        'checklist': checklist.map((item) => item.toMap()).toList(),
    };
  }
}

class StoredEventRecurrence {
  StoredEventRecurrence({
    required this.startDate,
    required this.frequency,
    required this.until,
    this.daysOfWeek = const [],
  });

  final DateTime startDate;
  final int frequency;
  final DateTime until;
  final List<int> daysOfWeek;

  factory StoredEventRecurrence.fromMap(Map<String, dynamic> map) {
    final rawDays = map['daysOfWeek'] as List?;
    return StoredEventRecurrence(
      startDate: DateTime.parse(map['startDate'] as String).toLocal(),
      frequency: map['frequency'] as int,
      until: DateTime.parse(map['until'] as String).toLocal(),
      daysOfWeek: rawDays
              ?.map((day) {
                if (day is Map) return day['day'] as int;
                return day as int;
              })
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'frequency': frequency,
      'occurrences': 0,
      'until': until.toIso8601String(),
      if (daysOfWeek.isNotEmpty)
        'daysOfWeek': daysOfWeek.map((day) => {'day': day}).toList(),
    };
  }
}

class StoredChecklistItem {
  StoredChecklistItem({required this.text, required this.isDone});

  final String text;
  final bool isDone;

  factory StoredChecklistItem.fromMap(Map<String, dynamic> map) {
    return StoredChecklistItem(
      text: map['text'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {'text': text, 'isDone': isDone};
}

class CalendarEventOccurrence {
  CalendarEventOccurrence({
    required this.event,
    required this.day,
    required this.displayStart,
    required this.displayEnd,
  });

  final StoredCalendarEvent event;
  final DateTime day;
  final DateTime displayStart;
  final DateTime displayEnd;
}
