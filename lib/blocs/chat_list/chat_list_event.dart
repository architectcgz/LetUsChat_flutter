part of 'chat_list_bloc.dart';

sealed class ChatListEvent {
  const ChatListEvent();
}

final class GetUnreadMsgEvent extends ChatListEvent {
  final String userId;
  GetUnreadMsgEvent({required this.userId});
}

final class LoadChatListEvent extends ChatListEvent {}

final class AddToChatListEvent extends ChatListEvent {
  final RecentChat recentChat;
  AddToChatListEvent({required this.recentChat});
}

final class ClearRecentChatHistoryEvent extends ChatListEvent {
  final String chatId;
  ClearRecentChatHistoryEvent({required this.chatId});
}

final class ReceiveNewMessageEvent extends ChatListEvent {
  final MessageDto message;
  ReceiveNewMessageEvent({required this.message});
}

final class PinChatEvent extends ChatListEvent {
  final ChatItem chatItem;
  PinChatEvent({required this.chatItem});
}

final class RemoveFromChatListEvent extends ChatListEvent {
  final String chatId;
  RemoveFromChatListEvent({required this.chatId});
}

final class ReadMessageEvent extends ChatListEvent {
  final String chatId;
  ReadMessageEvent({required this.chatId});
}

final class SendMessageEvent extends ChatListEvent {
  final MessageDto message;
  SendMessageEvent({required this.message});
}

final class DeleteRecentChatEvent extends ChatListEvent {
  final String chatId;
  DeleteRecentChatEvent({required this.chatId});
}

final class UpdateRecentChatEvent extends ChatListEvent{
  final MessageDto message;
  UpdateRecentChatEvent({required this.message});
}
