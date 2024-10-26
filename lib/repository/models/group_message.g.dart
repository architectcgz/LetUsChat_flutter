// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupMessageAdapter extends TypeAdapter<GroupMessage> {
  @override
  final int typeId = 5;

  @override
  GroupMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupMessage(
      groupId: fields[0] as String,
      messageId: fields[1] as String,
      senderId: fields[2] as String,
      messageType: fields[3] as int,
      status: fields[4] as int,
      content: fields[5] as String?,
      sendTime: fields[6] as DateTime,
      mediaName: fields[7] as String?,
      mediaUrl: fields[8] as String?,
      mediaSize: fields[9] as double?,
      localMediaPath: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GroupMessage obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.messageId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.messageType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.content)
      ..writeByte(6)
      ..write(obj.sendTime)
      ..writeByte(7)
      ..write(obj.mediaName)
      ..writeByte(8)
      ..write(obj.mediaUrl)
      ..writeByte(9)
      ..write(obj.mediaSize)
      ..writeByte(10)
      ..write(obj.localMediaPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
