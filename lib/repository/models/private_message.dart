import 'package:hive/hive.dart';

part 'private_message.g.dart';

@HiveType(typeId: 6)
class PrivateMessage extends HiveObject {
  @HiveField(0)
  String friendId;

  @HiveField(1)
  String messageId;

  @HiveField(2)
  bool isSender;

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
  double? mediaSize;//对于音频消息,这里表示音频的时长  其他的消息,表示文件的大小

  @HiveField(10)
  String? localMediaPath;

//<editor-fold desc="Data Methods">
  PrivateMessage({
    required this.friendId,
    required this.messageId,
    required this.isSender,
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
      (other is PrivateMessage &&
          runtimeType == other.runtimeType &&
          friendId == other.friendId &&
          messageId == other.messageId &&
          isSender == other.isSender &&
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
      friendId.hashCode ^
      messageId.hashCode ^
      isSender.hashCode ^
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
    return 'PrivateMessage{ friendId: $friendId, messageId: $messageId, isSender: $isSender, messageType: $messageType, status: $status, content: $content, sendTime: $sendTime, mediaName: $mediaName, mediaUrl: $mediaUrl, mediaSize: $mediaSize, localMediaPath: $localMediaPath,}';
  }

  PrivateMessage copyWith({
    String? friendId,
    String? messageId,
    bool? isSender,
    int? messageType,
    int? status,
    String? content,
    DateTime? sendTime,
    String? mediaName,
    String? mediaUrl,
    double? mediaSize,
    String? localMediaPath,
  }) {
    return PrivateMessage(
      friendId: friendId ?? this.friendId,
      messageId: messageId ?? this.messageId,
      isSender: isSender ?? this.isSender,
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
      'friendId': friendId,
      'messageId': messageId,
      'isSender': isSender,
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

  factory PrivateMessage.fromMap(Map<String, dynamic> map) {
    return PrivateMessage(
      friendId: map['friendId'] as String,
      messageId: map['messageId'] as String,
      isSender: map['isSender'] as bool,
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
