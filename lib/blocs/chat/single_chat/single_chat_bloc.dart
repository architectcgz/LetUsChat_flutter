import 'dart:async';
import 'package:let_us_chat/blocs/chat/abstract_chat/abstract_chat_bloc.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/services/file_service.dart';
import 'package:let_us_chat/core/services/private_msg_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/models/message_send_result.dart';
import 'package:let_us_chat/repository/local/local_private_message_repo.dart';
import 'package:let_us_chat/repository/models/private_message.dart';
import 'package:let_us_chat/repository/models/recent_chat.dart';
import 'package:uuid/uuid.dart';

import '../../../models/message.dart';
import '../../../repository/models/friend.dart';

class SingleChatBloc extends AbstractChatBloc {
  final privateMessageService = serviceLocator.get<PrivateMessageService>();
  final fileService = serviceLocator.get<FileService>();
  late Friend friend;
  DateTime? lastMessageTime;

  SingleChatBloc();

  @override
  FutureOr<void> onInitializeChat(event, emit) async {
    friend = event.friend;
  }

  @override
  FutureOr<void> onReceiveMessage(event, emit) async {
    final localPrivateMessageRepo =
        serviceLocator.get<LocalPrivateMessageRepo>();
    final message = event.message;
    print("在singleChatPage收到了好友消息: $message");
    await localPrivateMessageRepo.saveMessage(PrivateMessage(
        friendId: message.senderId,
        messageId: message.messageId!,
        content: message.content,
        mediaName: message.mediaName,
        mediaSize: message.mediaSize,
        mediaUrl: message.mediaUrl,
        isSender: false,
        messageType: message.messageType.code,
        status: message.messageStatus.code,
        sendTime: message.sendTime));
    serviceLocator
        .get<RecentChatListBloc>()
        .add(UpdateRecentChatEvent(message: message));
    print("将UpdateRecentChatEvent 挂载到chatListBloc");
    emit(NewChatMessageHasReceived(message: event.message));
  }

  @override
  FutureOr<void> onClearChatHistory(event, emit) async {
    final localPrivateMessageRepo =
        serviceLocator.get<LocalPrivateMessageRepo>();
    await localPrivateMessageRepo.deleteMessagesByFriendId(friend.userId);
    serviceLocator
        .get<RecentChatListBloc>()
        .add(ClearRecentChatHistoryEvent(chatId: friend.userId));
    emit(ChatHistoryCleared());
  }

  @override
  FutureOr<void> onSendMessage(event, emit) async {
    event.message.messageId = Uuid().v1();
    emit(SendingMessage(message: event.message));
    print("修改状态为发送中,本次发送的消息: ${event.message.toString()}");
    final message = event.message;

    final localPrivateMessageRepo =
        serviceLocator.get<LocalPrivateMessageRepo>();
    MessageSendResult result;
    String? uploadResult;
    String? errorMessage;
    if (message.chatType == ChatType.singleChat) {
      switch (message.messageType) {
        case MessageType.text:
          errorMessage = null;
          break;
        case MessageType.recall:
          errorMessage = null;
          break;
        case MessageType.image:
          //如果发送的是图片或音频,先把文件上传到服务器
          uploadResult = await fileService.uploadImage(message.cachedMedia!);
          errorMessage = "图片发送失败";
        case MessageType.file:
          errorMessage = "文件发送失败";
        case MessageType.video:
          errorMessage = "视频发送失败";
        case MessageType.voice:
          uploadResult = await fileService.uploadVoice(message.cachedMedia!);
          errorMessage = "语音上传失败";
          break;
      }
      if (errorMessage != null) {
        if (uploadResult == null) {
          emit(SendMessageFailed(
              errorMessage: errorMessage, messageId: message.messageId!));
          await localPrivateMessageRepo.saveMessage(PrivateMessage(
              friendId: message.receiverId,
              messageId: message.messageId!,
              isSender: true,
              messageType: message.messageType.code,
              mediaSize: message.mediaSize,
              status: MessageStatus.failed.code,
              localMediaPath: message.cachedMedia!.path,
              sendTime: message.sendTime));
          return;
        }
        message.mediaUrl = uploadResult;
      }

      try {
        print("发送的资源文件url为${message.mediaUrl}");
        result = await privateMessageService.sendMessage(message);
        message.sendTime = result.sendTime;
        message.messageId = result.messageId.toString();
        message.messageStatus = MessageStatus.sent; //修改消息发送状态为成功
        print("保存信息: ${message.toString()}");
        print("文件上传后的url为: $uploadResult!");
        await localPrivateMessageRepo.saveMessage(PrivateMessage(
            friendId: message.receiverId,
            messageId: message.messageId!,
            mediaName: message.mediaName,
            mediaUrl: uploadResult,
            mediaSize: message.mediaSize,
            content: message.content,
            isSender: true,
            messageType: message.messageType.code,
            status: message.messageStatus.code,
            sendTime: message.sendTime));
        serviceLocator
            .get<RecentChatListBloc>()
            .add(SendMessageEvent(message: message));
        print("修改状态为发送成功");
        emit(SendMessageSucceed(message: message));
        var recentChatExist = serviceLocator
            .get<RecentChatListBloc>()
            .recentChatList
            .where((e) => e.chatId == message.receiverId)
            .firstOrNull;
        if (recentChatExist == null) {
          serviceLocator.get<RecentChatListBloc>().add(AddToChatListEvent(
                recentChat: RecentChat(
                    chatId: message.receiverId,
                    chatType: ChatType.singleChat.code,
                    lastMessage: message.content ?? "",
                    messageType: message.messageType.code,
                    lastChatTime: message.sendTime,
                    unreadCount: 0,
                    isMute: false,
                    isPinned: false,
                    updateTime: DateTime.now()),
              ));
        }
      } on CustomException catch (e) {
        await localPrivateMessageRepo.saveMessage(PrivateMessage(
            friendId: message.receiverId,
            messageId: message.messageId!,
            localMediaPath: message.cachedMedia?.path,
            isSender: true,
            messageType: message.messageType.code,
            mediaUrl: message.mediaUrl,
            mediaName: message.mediaName,
            mediaSize: message.mediaSize,
            status: MessageStatus.failed.code,
            sendTime: message.sendTime));

        print("由于${e.toString()},消息发送失败,生成的随机uuid: ${message.messageId}");
        emit(SendMessageFailed(
            errorMessage: e.message, messageId: message.messageId!));
      }
    }
  }

  @override
  FutureOr<void> onLoadMoreChatHistory(event, emit) async {
    final privateMessageRepo = serviceLocator.get<LocalPrivateMessageRepo>();
    emit(LoadingMoreChatHistory());

    // 由此次20条最早的那一条聊天记录获取其他的聊天记录
    final moreMessages = privateMessageRepo.getMessagesByFriendId(friend.userId,
        limit: 20, lastMessageTime: lastMessageTime);
    print("此次获取到的消息记录条数: ${moreMessages.length}");
    if (moreMessages.isNotEmpty) {
      var list = moreMessages.map((e) {
        //print("加载出的历史消息记录: ${e.toString()}");
        return MessageDto(
          messageId: e.messageId,
          senderId: e.isSender ? currentUserId! : e.friendId,
          receiverId: e.isSender ? e.friendId : currentUserId!,
          messageType: MessageType.fromCode(e.messageType)!,
          content: e.content,
          sendTime: e.sendTime,
          mediaName: e.mediaName,
          mediaUrl: e.mediaUrl,
          mediaSize: e.mediaSize,
          chatType: ChatType.fromCode(ChatType.singleChat.code)!,
          messageStatus: MessageStatus.fromCode(e.status)!,
        );
      }).toList();
      //更新本次20条消息最后一条的发送时间
      lastMessageTime = list.last.sendTime;
      emit(LoadMoreChatHistorySucceed(chatHistory: list));
    } else {
      emit(NoMoreChatHistory());
    }
  }

  @override
  FutureOr<void> onLoadChatHistory(event, emit) async {
    emit(LoadingChatHistory());
    final privateMessageRepo = serviceLocator.get<LocalPrivateMessageRepo>();
    //await privateMessageRepo.deleteAllMessages();
    final friendChatHistory =
        privateMessageRepo.getMessagesByFriendId(friend.userId, limit: 20);
    print("旧消息记录的数量: ${friendChatHistory.length}");
    var messageHistory = friendChatHistory.map((e) {
      //print(e.toString());
      return MessageDto(
          messageId: e.messageId,
          senderId: e.isSender ? currentUserId! : e.friendId,
          receiverId: e.isSender ? e.friendId : currentUserId!,
          messageType: MessageType.fromCode(e.messageType)!,
          content: e.content,
          mediaUrl: e.mediaUrl,
          mediaSize: e.mediaSize,
          mediaName: e.mediaName,
          messageStatus: MessageStatus.fromCode(e.status)!,
          sendTime: e.sendTime,
          chatType: ChatType.fromCode(ChatType.singleChat.code)!);
    }).toList();
    lastMessageTime =
        messageHistory.isEmpty ? null : messageHistory.last.sendTime;
    emit(ChatHistoryLoaded(chatHistory: messageHistory));
  }
}
