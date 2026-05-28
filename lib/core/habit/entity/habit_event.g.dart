// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitEventAdapter extends TypeAdapter<HabitEvent> {
  @override
  final typeId = 1;

  @override
  HabitEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitEvent(
      id: fields[0] as String,
      habitId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      valueLogged: fields[3] as double,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitEvent obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
