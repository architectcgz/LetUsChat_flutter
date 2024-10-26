import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:let_us_chat/blocs/chat/abstract_chat/abstract_chat_bloc.dart';
import 'package:let_us_chat/core/services/group_msg_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import '../../../core/constants/enums.dart';
import '../../../core/errors/exception.dart';
import '../../../repository/local/local_group_message_repo.dart';
import '../../../repository/models/group_message.dart';

class GroupChatBloc extends AbstractChatBloc {
  @override
  FutureOr<void> onInitializeChat(
      InitializeChatEvent event, Emitter<AbstractChatState> emit) {}

  @override
  FutureOr<void> onLoadChatHistory(
      LoadChatHistoryEvent event, Emitter<AbstractChatState> emit) {
//
  }

  @override
  FutureOr<void> onLoadMoreChatHistory(
      LoadMoreChatHistoryEvent event, Emitter<AbstractChatState> emit) {
//
  }

  @override
  FutureOr<void> onSendMessage(
      SendChatMsgEvent event, Emitter<AbstractChatState> emit) async {
    var message = event.message;
    final groupMessageService = serviceLocator.get<GroupMessageService>();
    final localGroupMessageRepo = serviceLocator.get<LocalGroupMessageRepo>();
    try {
      final result = await groupMessageService.sendMessage(message);
      message.sendTime = result.sendTime;
      message.messageId = result.messageId.toString();
      message.messageStatus = MessageStatus.sent;
      await localGroupMessageRepo.saveGroupMessage(GroupMessage(
          messageId: message.messageId!.toString(),
          groupId: message.receiverId,
          senderId: message.senderId,
          content: message.content,
          messageType: message.messageType.code,
          status: message.messageStatus.code,
          sendTime: message.sendTime));
      emit(SendMessageSucceed(message: message));
    } on CustomException catch (e) {
      emit(SendMessageFailed(messageId: '', errorMessage: e.message));
    }
  }

  @override
  FutureOr<void> onClearChatHistory(
      ClearChatHistoryEvent event, Emitter<AbstractChatState> emit) {
//
  }

  @override
  FutureOr<void> onReceiveMessage(
      NewMessageReceived event, Emitter<AbstractChatState> emit) {
//
  }
}
