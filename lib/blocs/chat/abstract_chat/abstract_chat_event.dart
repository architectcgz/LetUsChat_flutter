part of 'abstract_chat_bloc.dart';

@immutable
abstract class AbstractChatEvent {}
final class  InitializeChatEvent extends  AbstractChatEvent{
  final Friend friend;
  InitializeChatEvent({required this.friend});
}

final class LoadChatHistoryEvent extends  AbstractChatEvent{

}

final class UploadImageEvent extends  AbstractChatEvent{
  final List<File> imageList;
  UploadImageEvent({required this.imageList});
}

final class SendChatMsgEvent extends  AbstractChatEvent{
  final MessageDto message;
  SendChatMsgEvent({required this.message});
}

final class LoadMoreChatHistoryEvent extends  AbstractChatEvent{
  LoadMoreChatHistoryEvent();
}

final class ClearChatHistoryEvent extends  AbstractChatEvent{

}

final class NewMessageReceived extends  AbstractChatEvent{
  final MessageDto message;
  NewMessageReceived({required this.message});
}

final class RecallMessageEvent extends  AbstractChatEvent{
  final String messageId;
  RecallMessageEvent({required this.messageId});
}