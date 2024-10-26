// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentChatAdapter extends TypeAdapter<RecentChat> {
  @override
  final int typeId = 3;

  @override
  RecentChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentChat(
      chatId: fields[0] as String,
      chatType: fields[1] as int,
      lastSendUser: fields[2] as String?,
      lastMessage: fields[3] as String,
      messageType: fields[4] as int,
      lastChatTime: fields[5] as DateTime,
      unreadCount: fields[6] as int,
      isMute: fields[7] as bool,
      isPinned: fields[8] as bool,
      updateTime: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecentChat obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.chatId)
      ..writeByte(1)
      ..write(obj.chatType)
      ..writeByte(2)
      ..write(obj.lastSendUser)
      ..writeByte(3)
      ..write(obj.lastMessage)
      ..writeByte(4)
      ..write(obj.messageType)
      ..writeByte(5)
      ..write(obj.lastChatTime)
      ..writeByte(6)
      ..write(obj.unreadCount)
      ..writeByte(7)
      ..write(obj.isMute)
      ..writeByte(8)
      ..write(obj.isPinned)
      ..writeByte(9)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
