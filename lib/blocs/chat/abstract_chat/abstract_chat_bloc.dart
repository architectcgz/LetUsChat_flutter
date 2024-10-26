import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/message.dart';
import '../../../repository/models/friend.dart';

part 'abstract_chat_event.dart';
part 'abstract_chat_state.dart';

abstract class AbstractChatBloc
    extends Bloc<AbstractChatEvent, AbstractChatState> {
  AbstractChatBloc() : super(AbstractChatInitial()) {
    on<InitializeChatEvent>(onInitializeChat);
    on<LoadChatHistoryEvent>(onLoadChatHistory);
    on<LoadMoreChatHistoryEvent>(onLoadMoreChatHistory);
    on<SendChatMsgEvent>(onSendMessage);
    on<ClearChatHistoryEvent>(onClearChatHistory);
    on<NewMessageReceived>(onReceiveMessage);
  }
  FutureOr<void> onInitializeChat(
      InitializeChatEvent event, Emitter<AbstractChatState> emit) async {}

  FutureOr<void> onReceiveMessage(
      NewMessageReceived event, Emitter<AbstractChatState> emit) async {}

  FutureOr<void> onClearChatHistory(
      ClearChatHistoryEvent event, Emitter<AbstractChatState> emit) async {}

  FutureOr<void> onSendMessage(
      SendChatMsgEvent event, Emitter<AbstractChatState> emit) async {}

  FutureOr<void> onLoadMoreChatHistory(
      LoadMoreChatHistoryEvent event, Emitter<AbstractChatState> emit) async {}

  FutureOr<void> onLoadChatHistory(
      LoadChatHistoryEvent event, Emitter<AbstractChatState> emit) async {}
}
