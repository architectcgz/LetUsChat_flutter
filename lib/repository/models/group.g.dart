// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 2;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(
      groupId: fields[0] as String,
      groupName: fields[1] as String,
      groupAlias: fields[2] as String?,
      groupAvatar: fields[3] as String,
      leaderId: fields[4] as String,
      joinType: fields[5] as int?,
      status: fields[6] as int,
      pinned: fields[7] as bool,
      muted: fields[8] as bool,
      createTime: fields[9] as DateTime,
      updateTime: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.groupAlias)
      ..writeByte(3)
      ..write(obj.groupAvatar)
      ..writeByte(4)
      ..write(obj.leaderId)
      ..writeByte(5)
      ..write(obj.joinType)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.pinned)
      ..writeByte(8)
      ..write(obj.muted)
      ..writeByte(9)
      ..write(obj.createTime)
      ..writeByte(10)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
