part of 'abstract_chat_bloc.dart';

@immutable
abstract class AbstractChatState {}

final class AbstractChatInitial extends AbstractChatState {}

final class SendingMessage extends AbstractChatState {
  final MessageDto message;
  SendingMessage({required this.message});
}

final class SendMessageSucceed extends AbstractChatState {
  final MessageDto message;
  SendMessageSucceed({required this.message});
}

final class SendMessageFailed extends AbstractChatState {
  final String messageId;
  final String errorMessage;
  SendMessageFailed({required this.messageId, required this.errorMessage});
}

final class LoadingChatHistory extends AbstractChatState {}

final class ChatHistoryLoaded extends AbstractChatState {
  final List<MessageDto> chatHistory;
  ChatHistoryLoaded({required this.chatHistory});
}

final class LoadChatHistoryFailed extends AbstractChatState {
  final String message;
  LoadChatHistoryFailed({required this.message});
}

final class LoadingMoreChatHistory extends AbstractChatState {}

final class LoadMoreChatHistorySucceed extends AbstractChatState {
  final List<MessageDto> chatHistory;
  LoadMoreChatHistorySucceed({required this.chatHistory});
}

final class LoadMoreChatHistoryFailed extends AbstractChatState {
  final String message;
  LoadMoreChatHistoryFailed({required this.message});
}

final class NoMoreChatHistory extends AbstractChatState {}

final class NewChatMessageHasReceived extends AbstractChatState {
  final MessageDto message;
  NewChatMessageHasReceived({required this.message});
}

final class ChatHistoryCleared extends AbstractChatState {}

final class UploadingImage extends AbstractChatState {}

final class ImageUploaded extends AbstractChatState {}

final class ImageUploadFailed extends AbstractChatState {}
