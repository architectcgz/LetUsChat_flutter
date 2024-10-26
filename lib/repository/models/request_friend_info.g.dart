// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_friend_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestFriendInfoAdapter extends TypeAdapter<RequestFriendInfo> {
  @override
  final int typeId = 4;

  @override
  RequestFriendInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestFriendInfo(
      friendUid: fields[0] as String,
      nickname: fields[1] as String,
      avatar: fields[2] as String,
      gender: fields[3] as int?,
      location: fields[4] as String?,
      requestMessage: fields[5] as String?,
      createTime: fields[7] as DateTime,
      updateTime: fields[8] as DateTime,
      status: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RequestFriendInfo obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.friendUid)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.avatar)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.requestMessage)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createTime)
      ..writeByte(8)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestFriendInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
