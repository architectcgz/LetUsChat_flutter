import 'package:intl/intl.dart';
import 'package:let_us_chat/core/constants/enums.dart';

class ChatItem {
  final String chatName;
  bool isPinned;
  String lastMessage;
  DateTime lastChatTime;
  final String avatarUrl;
  int unreadCount;
  final ChatType chatType;
  final String chatId;


  String getFormattedTime() {
    final now = DateTime.now();
    lastChatTime = lastChatTime.toLocal();
    final difference = _daysBetween(lastChatTime, now);
    //今天内的聊天,显示 HH:mm
    if (difference == 0) {
      return DateFormat('HH:mm').format(lastChatTime);
    }
    //昨天内的聊天,显示昨天
    if (difference == 1) {
      return '昨天';
    }
    //今年内的聊天, 显示MM-dd
    if (lastChatTime.year == now.year) {
      return DateFormat('MM-dd').format(lastChatTime);
    }
    //今年外的聊天,显示具体年月日
    return DateFormat('yyyy-MM-dd').format(lastChatTime);
  }

  int _daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

//<editor-fold desc="Data Methods">
  ChatItem({
    required this.chatName,
    required this.isPinned,
    required this.lastMessage,
    required this.lastChatTime,
    required this.avatarUrl,
    required this.unreadCount,
    required this.chatType,
    required this.chatId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatItem &&
          runtimeType == other.runtimeType &&
          chatName == other.chatName &&
          isPinned == other.isPinned &&
          lastMessage == other.lastMessage &&
          lastChatTime == other.lastChatTime &&
          avatarUrl == other.avatarUrl &&
          unreadCount == other.unreadCount &&
          chatType == other.chatType &&
          chatId == other.chatId);

  @override
  int get hashCode =>
      chatName.hashCode ^
      isPinned.hashCode ^
      lastMessage.hashCode ^
      lastChatTime.hashCode ^
      avatarUrl.hashCode ^
      unreadCount.hashCode ^
      chatType.hashCode ^
      chatId.hashCode;

  @override
  String toString() {
    return 'ChatItem{ chatName: $chatName, isPinned: $isPinned, lastMessage: $lastMessage, lastChatTime: $lastChatTime, avatarUrl: $avatarUrl, unreadCount: $unreadCount, chatType: $chatType, chatId: $chatId,}';
  }

  ChatItem copyWith({
    String? chatName,
    bool? isPinned,
    String? lastMessage,
    DateTime? lastChatTime,
    String? avatarUrl,
    int? unreadCount,
    ChatType? chatType,
    String? chatId,
  }) {
    return ChatItem(
      chatName: chatName ?? this.chatName,
      isPinned: isPinned ?? this.isPinned,
      lastMessage: lastMessage ?? this.lastMessage,
      lastChatTime: lastChatTime ?? this.lastChatTime,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      chatType: chatType ?? this.chatType,
      chatId: chatId ?? this.chatId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatName': chatName,
      'isPinned': isPinned,
      'lastMessage': lastMessage,
      'lastChatTime': lastChatTime,
      'avatarUrl': avatarUrl,
      'unreadCount': unreadCount,
      'chatType': chatType,
      'chatId': chatId,
    };
  }

  factory ChatItem.fromMap(Map<String, dynamic> map) {
    return ChatItem(
      chatName: map['chatName'] as String,
      isPinned: map['isPinned'] as bool,
      lastMessage: map['lastMessage'] as String,
      lastChatTime: map['lastChatTime'] as DateTime,
      avatarUrl: map['avatarUrl'] as String,
      unreadCount: map['unreadCount'] as int,
      chatType: map['chatType'] as ChatType,
      chatId: map['chatId'] as String,
    );
  }

//</editor-fold>
}
