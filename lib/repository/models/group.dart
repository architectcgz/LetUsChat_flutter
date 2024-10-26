import 'package:hive/hive.dart';
part 'group.g.dart';
//dart run build_runner build
@HiveType(typeId: 2)
class Group{
  @HiveField(0)
  String groupId;
  @HiveField(1)
  String groupName;
  @HiveField(2)
  String? groupAlias;
  @HiveField(3)
  String groupAvatar;
  @HiveField(4)
  String leaderId;
  @HiveField(5)
  int? joinType;
  @HiveField(6)
  int status;//0 正常 1群被解散 2群被封禁
  @HiveField(7)
  bool pinned;
  @HiveField(8)
  bool muted;
  @HiveField(9)
  DateTime createTime;
  @HiveField(10)
  DateTime updateTime;

//<editor-fold desc="Data Methods">
  Group({
    required this.groupId,
    required this.groupName,
    this.groupAlias,
    required this.groupAvatar,
    required this.leaderId,
    this.joinType,
    required this.status,
    required this.pinned,
    required this.muted,
    required this.createTime,
    required this.updateTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          groupName == other.groupName &&
          groupAlias == other.groupAlias &&
          groupAvatar == other.groupAvatar &&
          leaderId == other.leaderId &&
          joinType == other.joinType &&
          status == other.status &&
          pinned == other.pinned &&
          muted == other.muted &&
          createTime == other.createTime &&
          updateTime == other.updateTime);

  @override
  int get hashCode =>
      groupId.hashCode ^
      groupName.hashCode ^
      groupAlias.hashCode ^
      groupAvatar.hashCode ^
      leaderId.hashCode ^
      joinType.hashCode ^
      status.hashCode ^
      pinned.hashCode ^
      muted.hashCode ^
      createTime.hashCode ^
      updateTime.hashCode;

  @override
  String toString() {
    return 'Group{ groupId: $groupId, groupName: $groupName, groupAlias: $groupAlias, groupAvatar: $groupAvatar, leaderId: $leaderId, joinType: $joinType, status: $status, pinned: $pinned, muted: $muted, createTime: $createTime, updateTime: $updateTime,}';
  }

  Group copyWith({
    String? groupId,
    String? groupName,
    String? groupAlias,
    String? groupAvatar,
    String? leaderId,
    int? joinType,
    int? status,
    bool? pinned,
    bool? muted,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupAlias: groupAlias ?? this.groupAlias,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      leaderId: leaderId ?? this.leaderId,
      joinType: joinType ?? this.joinType,
      status: status ?? this.status,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupAlias': groupAlias,
      'groupAvatar': groupAvatar,
      'leaderId': leaderId,
      'joinType': joinType,
      'status': status,
      'pinned': pinned,
      'muted': muted,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      groupAlias: map['groupAlias'] as String,
      groupAvatar: map['groupAvatar'] as String,
      leaderId: map['leaderId'] as String,
      joinType: map['joinType'] as int,
      status: map['status'] as int,
      pinned: map['pinned'] as bool,
      muted: map['muted'] as bool,
      createTime: map['createTime'] as DateTime,
      updateTime: map['updateTime'] as DateTime,
    );
  }

//</editor-fold>
}