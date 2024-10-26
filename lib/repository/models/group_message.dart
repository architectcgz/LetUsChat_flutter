import 'package:hive/hive.dart';

part 'group_message.g.dart';

//flutter packages pub run build_runner build
@HiveType(typeId: 5)
class GroupMessage extends HiveObject {
  @HiveField(0)
  String groupId;

  @HiveField(1)
  String messageId;

  @HiveField(2)
  String senderId;

  @HiveField(3)
  int messageType;

  @HiveField(4)
  int status;

  @HiveField(5)
  String? content;

  @HiveField(6)
  DateTime sendTime;

  @HiveField(7)
  String? mediaName;

  @HiveField(8)
  String? mediaUrl;

  @HiveField(9)
  double? mediaSize;

  @HiveField(10)
  String? localMediaPath;

//<editor-fold desc="Data Methods">
  GroupMessage({
    required this.groupId,
    required this.messageId,
    required this.senderId,
    required this.messageType,
    required this.status,
    this.content,
    required this.sendTime,
    this.mediaName,
    this.mediaUrl,
    this.mediaSize,
    this.localMediaPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupMessage &&
          runtimeType == other.runtimeType &&
          groupId == other.groupId &&
          messageId == other.messageId &&
          senderId == other.senderId &&
          messageType == other.messageType &&
          status == other.status &&
          content == other.content &&
          sendTime == other.sendTime &&
          mediaName == other.mediaName &&
          mediaUrl == other.mediaUrl &&
          mediaSize == other.mediaSize &&
          localMediaPath == other.localMediaPath);

  @override
  int get hashCode =>
      groupId.hashCode ^
      messageId.hashCode ^
      senderId.hashCode ^
      messageType.hashCode ^
      status.hashCode ^
      content.hashCode ^
      sendTime.hashCode ^
      mediaName.hashCode ^
      mediaUrl.hashCode ^
      mediaSize.hashCode ^
      localMediaPath.hashCode;

  @override
  String toString() {
    return 'GroupMessage{ groupId: $groupId, messageId: $messageId, senderId: $senderId, messageType: $messageType, status: $status, content: $content, sendTime: $sendTime, mediaName: $mediaName, mediaUrl: $mediaUrl, mediaSize: $mediaSize, localMediaPath: $localMediaPath,}';
  }

  GroupMessage copyWith({
    String? groupId,
    String? messageId,
    String? senderId,
    int? messageType,
    int? status,
    String? content,
    DateTime? sendTime,
    String? mediaName,
    String? mediaUrl,
    double? mediaSize,
    String? localMediaPath,
  }) {
    return GroupMessage(
      groupId: groupId ?? this.groupId,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      content: content ?? this.content,
      sendTime: sendTime ?? this.sendTime,
      mediaName: mediaName ?? this.mediaName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaSize: mediaSize ?? this.mediaSize,
      localMediaPath: localMediaPath ?? this.localMediaPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'messageId': messageId,
      'senderId': senderId,
      'messageType': messageType,
      'status': status,
      'content': content,
      'sendTime': sendTime,
      'mediaName': mediaName,
      'mediaUrl': mediaUrl,
      'mediaSize': mediaSize,
      'localMediaPath': localMediaPath,
    };
  }

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      groupId: map['groupId'] as String,
      messageId: map['messageId'] as String,
      senderId: map['senderId'] as String,
      messageType: map['messageType'] as int,
      status: map['status'] as int,
      content: map['content'] as String,
      sendTime: map['sendTime'] as DateTime,
      mediaName: map['mediaName'] as String,
      mediaUrl: map['mediaUrl'] as String,
      mediaSize: map['mediaSize'] as double,
      localMediaPath: map['localMediaPath'] as String,
    );
  }

//</editor-fold>
}
