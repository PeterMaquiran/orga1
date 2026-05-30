import 'package:hive_flutter/hive_flutter.dart';
import 'entity_event_recurrence.dart';

part 'entity_event.g.dart';

@HiveType(typeId: 2)
class Event extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  int? ownerType;

  @HiveField(3)
  String subject;

  @HiveField(4)
  String? body;

  @HiveField(5)
  String location;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime endDate;

  @HiveField(8)
  int? type;

  @HiveField(9)
  int? category;

  @HiveField(10)
  bool isRecurring;

  @HiveField(11)
  EventRecurrence? eventRecurrence;

  @HiveField(12)
  bool hasAttachments;

  @HiveField(13)
  bool isPrivate;

  @HiveField(14)
  bool isAllDayEvent;

  @HiveField(15)
  int status;

  @HiveField(16)
  bool isOffline;

  @HiveField(17)
  bool approveOffline = false;

  int? notificationId;

  Event({
    required this.id,
    this.userId,
    this.ownerType,
    required this.subject,
    this.body,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.type,
    this.category,
    required this.isRecurring,
    this.eventRecurrence,
    required this.hasAttachments,
    required this.isPrivate,
    required this.isAllDayEvent,
    required this.status,
    this.isOffline = false
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      userId: json["userId"],
      ownerType: json['ownerType'],
      subject: json['subject'],
      body: json['body'],
      location: json['location'] ?? "--",
      startDate: DateTime.parse(json['startDate']).toLocal(),
      endDate: DateTime.parse(json['endDate']).toLocal(),
      type: json['type'],
      category: json['category'],
      isRecurring: json['isRecurring'],
      eventRecurrence: json['eventRecurrence'] != null
          ? EventRecurrence.fromJson(json['eventRecurrence'])
          : null,
      // Handle null case
      hasAttachments: json['hasAttachments'],
      isPrivate: json['isPrivate'],
      isAllDayEvent: json['isAllDayEvent'],
      status: json['status'],
    );
  }
}
