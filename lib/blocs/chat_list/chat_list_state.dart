part of 'chat_list_bloc.dart';

sealed class ChatListState {
  const ChatListState();
}

///从本地sqlite读取聊天记录
final class ChatListInitial extends ChatListState {

}

final class ChatListLoading extends ChatListState{

}

final class LoadChatListSucceed extends ChatListState{
  final List<ChatItem?> chatItems;
  const LoadChatListSucceed({required this.chatItems});

}
final class ChatListEmpty extends ChatListState{

}
final class LoadChatListFailed extends ChatListState{
  final String? message;
  const LoadChatListFailed({required this.message});

}

///正在获取未读消息记录
final class GettingUnreadMsg extends ChatListState {

}

///获取未读消息成功
final class GetUnreadMsgSucceed extends ChatListState {
  final List<UnreadMessage> unreadList;
  const GetUnreadMsgSucceed({required this.unreadList});

}

final class GetUnreadMsgFailed extends ChatListState {
  final String message;
  final int code;
  late DateTime timestamp;
  GetUnreadMsgFailed({required this.message, required this.code}){
    timestamp = DateTime.timestamp();
  }

}

final class NewMessageReceived extends ChatListState{
  final ChatItem chatItem;
  const NewMessageReceived({required this.chatItem});

}

final class AddToChatListSucceed extends ChatListState{
  final ChatItem chatItem;
  const AddToChatListSucceed({required this.chatItem});

}

final class ClearRecentChatHistorySucceed extends ChatListState{
  final String chatId;
  const ClearRecentChatHistorySucceed({required this.chatId});

}

final class RecentChatUpdated extends ChatListState{
  final String chatId;
  final DateTime lastChatTime;
  final String lastMessage;
  const RecentChatUpdated({required this.chatId,required this.lastMessage,required this.lastChatTime});

}

final class ChatItemUpdated extends ChatListState{
  final ChatItem chatItem;
  const ChatItemUpdated({required this.chatItem});

}

final class DeleteChatSucceed extends ChatListState{
  final String chatId;
  const DeleteChatSucceed({required this.chatId});

}