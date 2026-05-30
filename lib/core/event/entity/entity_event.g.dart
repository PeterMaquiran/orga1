// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final typeId = 2;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(id: fields[0] as String, userId: fields[1] as String?, ownerType: fields[2] as int?, subject: fields[3] as String, body: fields[4] as String?, location: fields[5] as String, startDate: fields[6] as DateTime, endDate: fields[7] as DateTime, isRecurring: fields[8] as bool, hasAttachments: fields[9] as bool, isPrivate: fields[10] as bool, isAllDayEvent: fields[11] as bool, status: fields[12] as int); // TODO: Add userId, ownerType
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
