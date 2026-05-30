// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_event_recurrence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventRecurrenceAdapter extends TypeAdapter<EventRecurrence> {
  @override
  final typeId = 3;

  @override
  EventRecurrence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventRecurrence(startDate: fields[0] as DateTime, frequency: fields[1] as int, occurrences: fields[2] as int, until: fields[3] as DateTime, last: fields[4] as DateTime?, daysOfWeek: fields[5] as List<DayOfWeek>); // TODO: Add daysOfWeek
  }

  @override
  void write(BinaryWriter writer, EventRecurrence obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventRecurrenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
