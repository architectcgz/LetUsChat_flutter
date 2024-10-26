import 'package:hive/hive.dart';

part 'recent_chat.g.dart';

//flutter packages pub run build_runner build
@HiveType(typeId: 3)
class RecentChat {
  @HiveField(0)
  String chatId; // 对应的群聊id或者是用户id亦或是其他的Uid
  @HiveField(1)
  int chatType; //0: 单聊, 1:群聊

  @HiveField(2)
  String? lastSendUser; // 最后一个发消息的群成员id

  @HiveField(3)
  String lastMessage; // 最后一条发出或收到的消息

  @HiveField(4)
  int messageType; //消息类型 0:文字 1:图片 2:文件 3:视频 4: 语音 5:撤回消息

  @HiveField(5)
  DateTime lastChatTime; // 最后一次收到消息或发出消息的时间

  @HiveField(6)
  int unreadCount; // 未读消息条数

  @HiveField(7)
  bool isMute; //是否免打扰

  @HiveField(8)
  bool isPinned; //是否置顶

  @HiveField(9)
  DateTime updateTime;

//<editor-fold desc="Data Methods">
  RecentChat({
    required this.chatId,
    required this.chatType,
    this.lastSendUser,
    required this.lastMessage,
    required this.messageType,
    required this.lastChatTime,
    required this.unreadCount,
    required this.isMute,
    required this.isPinned,
    required this.updateTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentChat &&
          runtimeType == other.runtimeType &&
          chatId == other.chatId &&
          chatType == other.chatType &&
          lastSendUser == other.lastSendUser &&
          lastMessage == other.lastMessage &&
          messageType == other.messageType &&
          lastChatTime == other.lastChatTime &&
          unreadCount == other.unreadCount &&
          isMute == other.isMute &&
          isPinned == other.isPinned &&
          updateTime == other.updateTime);

  @override
  int get hashCode =>
      chatId.hashCode ^
      chatType.hashCode ^
      lastSendUser.hashCode ^
      lastMessage.hashCode ^
      messageType.hashCode ^
      lastChatTime.hashCode ^
      unreadCount.hashCode ^
      isMute.hashCode ^
      isPinned.hashCode ^
      updateTime.hashCode;

  @override
  String toString() {
    return 'RecentChat{ chatId: $chatId, chatType: $chatType, lastSendUser: $lastSendUser, lastMessage: $lastMessage, messageType: $messageType, lastChatTime: $lastChatTime, unreadCount: $unreadCount, isMute: $isMute, isTop: $isPinned, updateTime: $updateTime,}';
  }

  RecentChat copyWith({
    String? chatId,
    int? chatType,
    String? lastSendUser,
    String? lastMessage,
    int? messageType,
    DateTime? lastChatTime,
    int? unreadCount,
    bool? isMute,
    bool? isPinned,
    DateTime? updateTime,
  }) {
    return RecentChat(
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      lastSendUser: lastSendUser ?? this.lastSendUser,
      lastMessage: lastMessage ?? this.lastMessage,
      messageType: messageType ?? this.messageType,
      lastChatTime: lastChatTime ?? this.lastChatTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isMute: isMute ?? this.isMute,
      isPinned: isPinned ?? this.isPinned,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'chatType': chatType,
      'lastSendUser': lastSendUser,
      'lastMessage': lastMessage,
      'messageType': messageType,
      'lastChatTime': lastChatTime,
      'unreadCount': unreadCount,
      'isMute': isMute,
      'isTop': isPinned,
      'updateTime': updateTime,
    };
  }

  factory RecentChat.fromMap(Map<String, dynamic> map) {
    return RecentChat(
      chatId: map['chatId'] as String,
      chatType: map['chatType'] as int,
      lastSendUser: map['lastSendUser'] as String,
      lastMessage: map['lastMessage'] as String,
      messageType: map['messageType'] as int,
      lastChatTime: map['lastChatTime'] as DateTime,
      unreadCount: map['unreadCount'] as int,
      isMute: map['isMute'] as bool,
      isPinned: map['isTop'] as bool,
      updateTime: map['updateTime'] as DateTime,
    );
  }

//</editor-fold>
}
