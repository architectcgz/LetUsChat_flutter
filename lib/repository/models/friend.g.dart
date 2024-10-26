// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FriendAdapter extends TypeAdapter<Friend> {
  @override
  final int typeId = 1;

  @override
  Friend read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Friend(
      userId: fields[0] as String,
      phone: fields[1] as String?,
      email: fields[2] as String?,
      avatar: fields[3] as String,
      nickname: fields[4] as String,
      alias: fields[5] as String?,
      location: fields[6] as String?,
      gender: fields[7] as int?,
      signature: fields[8] as String?,
      pinned: fields[9] as bool,
      muted: fields[10] as bool,
      createTime: fields[11] as DateTime,
      updateTime: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Friend obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatar)
      ..writeByte(4)
      ..write(obj.nickname)
      ..writeByte(5)
      ..write(obj.alias)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.gender)
      ..writeByte(8)
      ..write(obj.signature)
      ..writeByte(9)
      ..write(obj.pinned)
      ..writeByte(10)
      ..write(obj.muted)
      ..writeByte(11)
      ..write(obj.createTime)
      ..writeByte(12)
      ..write(obj.updateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
