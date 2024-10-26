import 'dart:io';

import 'package:let_us_chat/core/constants/enums.dart';

class MessageDto {
  String? messageId;
  ChatType chatType;
  String? groupId;
  String senderId;
  String receiverId;
  MessageType messageType;
  MessageStatus messageStatus;
  String? content;
  String? mediaName;
  String? mediaUrl;
  File? cachedMedia;
  double? mediaSize;
  DateTime sendTime;

//<editor-fold desc="Data Methods">
  MessageDto({
    this.messageId,
    required this.chatType,
    this.groupId,
    required this.senderId,
    required this.receiverId,
    required this.messageType,
    required this.messageStatus,
    this.content,
    this.mediaName,
    this.mediaUrl,
    this.cachedMedia,
    this.mediaSize,
    required this.sendTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageDto &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          chatType == other.chatType &&
          groupId == other.groupId &&
          senderId == other.senderId &&
          receiverId == other.receiverId &&
          messageType == other.messageType &&
          messageStatus == other.messageStatus &&
          content == other.content &&
          mediaName == other.mediaName &&
          mediaUrl == other.mediaUrl &&
          cachedMedia == other.cachedMedia &&
          mediaSize == other.mediaSize &&
          sendTime == other.sendTime);

  @override
  int get hashCode =>
      messageId.hashCode ^
      chatType.hashCode ^
      groupId.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      messageType.hashCode ^
      messageStatus.hashCode ^
      content.hashCode ^
      mediaName.hashCode ^
      mediaUrl.hashCode ^
      cachedMedia.hashCode ^
      mediaSize.hashCode ^
      sendTime.hashCode;

  @override
  String toString() {
    return 'MessageDto{ messageId: $messageId, chatType: $chatType, groupId: $groupId, senderId: $senderId, receiverId: $receiverId, messageType: $messageType, messageStatus: $messageStatus, content: $content, mediaName: $mediaName, mediaUrl: $mediaUrl, cachedMedia: $cachedMedia, mediaSize: $mediaSize, sendTime: ${sendTime.toLocal()},}';
  }

  MessageDto copyWith({
    String? messageId,
    ChatType? chatType,
    String? groupId,
    String? senderId,
    String? receiverId,
    MessageType? messageType,
    MessageStatus? messageStatus,
    String? content,
    String? mediaName,
    String? mediaUrl,
    File? cachedMedia,
    double? mediaSize,
    DateTime? sendTime,
  }) {
    return MessageDto(
      messageId: messageId ?? this.messageId,
      chatType: chatType ?? this.chatType,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      messageType: messageType ?? this.messageType,
      messageStatus: messageStatus ?? this.messageStatus,
      content: content ?? this.content,
      mediaName: mediaName ?? this.mediaName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      cachedMedia: cachedMedia ?? this.cachedMedia,
      mediaSize: mediaSize ?? this.mediaSize,
      sendTime: sendTime ?? this.sendTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatType': chatType.code,
      'groupId': groupId,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': messageType.code,
      'messageStatus': messageStatus.code,
      'content': content,
      'mediaName': mediaName,
      'mediaUrl': mediaUrl,
      //'cachedMedia': cachedMedia, json不需要这个文件,已经上传到服务器
      'mediaSize': mediaSize,
      'sendTime': sendTime.toIso8601String(),
    };
  }

  factory MessageDto.fromMap(Map<String, dynamic> map) {
    return MessageDto(
      messageId: map['messageId'] as String,
      chatType: map['chatType'] as ChatType,
      groupId: map['groupId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      messageType: map['messageType'] as MessageType,
      messageStatus: map['messageStatus'] as MessageStatus,
      content: map['content'] as String,
      mediaName: map['mediaName'] as String,
      mediaUrl: map['mediaUrl'] as String,
      //cachedMedia: map['cachedMedia'] as File,  不用
      mediaSize: map['mediaSize'] as double,
      sendTime: map['sendTime'] as DateTime,
    );
  }

//</editor-fold>
}
