// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_day_of_week.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DayOfWeekAdapter extends TypeAdapter<DayOfWeek> {
  @override
  final typeId = 4;

  @override
  DayOfWeek read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DayOfWeek(day: fields[0] as int);
  }

  @override
  void write(BinaryWriter writer, DayOfWeek obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayOfWeekAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
