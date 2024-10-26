import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/navbar_bloc/navbar_bloc.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/core/services/user_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/repository/local/local_friend_repo.dart';
import 'package:let_us_chat/repository/local/local_group_message_repo.dart';
import 'package:let_us_chat/repository/local/local_private_message_repo.dart';
import 'package:let_us_chat/repository/local/local_recent_chat_repo.dart';
import 'package:let_us_chat/repository/models/group_message.dart';
import 'package:let_us_chat/repository/models/private_message.dart';
import 'package:let_us_chat/repository/models/recent_chat.dart';

import '../../models/chat_item.dart';
import '../../models/message.dart';
import '../../models/unread_message.dart';
import '../../repository/local/local_group_repo.dart';
import '../../repository/models/friend.dart';
import '../../repository/models/group.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class RecentChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final userService = serviceLocator.get<UserService>();
  List<RecentChat> recentChatList = [];
  final navbarBloc = serviceLocator.get<NavbarBloc>();
  int allUnReadMsgCount = 0; //用于计数,当数量=0时,消除掉导航栏下面的红点
  RecentChatListBloc() : super(ChatListInitial()) {
    on<LoadChatListEvent>(_onLoadChatList);
    on<AddToChatListEvent>(_onAddToChatList);
    on<ClearRecentChatHistoryEvent>((event, emit) async {
      final chatId = event.chatId;
      print("清理最近聊天信息...");
      RecentChat? recentChat =
          recentChatList.where((e) => e.chatId == chatId).firstOrNull;
      if (recentChat != null) {
        allUnReadMsgCount -= recentChat.unreadCount;
        recentChat.unreadCount = 0;
        recentChat.lastMessage = '';
        await serviceLocator
            .get<LocalRecentChatRepo>()
            .updateRecentChat(recentChat);
        emit(ClearRecentChatHistorySucceed(chatId: chatId));
      } else {
        print("找不到这个聊天,id:$chatId");
      }
    });
    on<ReadMessageEvent>((event, emit) async {
      final chatId = event.chatId;
      print("将消息设置为已读,当前未读消息数量为: $allUnReadMsgCount");
      RecentChat? recentChat =
          recentChatList.where((e) => e.chatId == chatId).firstOrNull;
      if (recentChat != null) {
        allUnReadMsgCount -= recentChat.unreadCount; //减去这个聊天的未读消息记录
        recentChat.unreadCount = 0;
        await serviceLocator
            .get<LocalRecentChatRepo>()
            .updateRecentChat(recentChat);

        // 更新聊天图标的红点状态
        if (allUnReadMsgCount == 0) {
          var badgeList = navbarBloc.badgeList;
          badgeList[0] = false;
          navbarBloc.add(UpdateBadgeEvent(badgeList: badgeList));
        }
        print("将消息设置为已读");
      } else {
        print("找不到这个聊天,id:$chatId");
      }
    });

    on<ReceiveNewMessageEvent>(_onReceiveNewMessage);

    on<PinChatEvent>((event, emit) async {
      print("PinChatEvent");
      final localRecentChatRepo = serviceLocator.get<LocalRecentChatRepo>();
      var chatItem = event.chatItem;
      var recentChat = localRecentChatRepo.getRecentChat(chatItem.chatId);
      if (recentChat != null) {
        recentChat.isPinned = !recentChat.isPinned;
        chatItem.isPinned = !chatItem.isPinned;
        await localRecentChatRepo.updateRecentChat(recentChat);
        emit(ChatItemUpdated(chatItem: chatItem));
      } else {
        print("这个聊天项无法找到");
      }
    });

    on<SendMessageEvent>((event, emit) async {
      final message = event.message;
      final String chatId;
      RecentChat? chat;
      final localRecentChatRepo = serviceLocator.get<LocalRecentChatRepo>();
      switch (message.chatType) {
        case ChatType.singleChat:
          chatId = message.receiverId;
          break;
        case ChatType.groupChat:
          chatId = message.groupId!;
          break;
      }
      chat = recentChatList.where((e) => e.chatId == chatId).firstOrNull;
      if (chat != null) {
        print("发送消息,更新chatList页面的信息");
        chat.lastChatTime = message.sendTime;
        chat.messageType = message.chatType.code;
        chat.lastMessage = _getLastMessage(message);
        await localRecentChatRepo.updateRecentChat(chat);
        emit(RecentChatUpdated(
            lastMessage: chat.lastMessage,
            lastChatTime: chat.lastChatTime,
            chatId: chatId));
      }
    });
  }

  FutureOr<void> _onReceiveNewMessage(
      ReceiveNewMessageEvent event, emit) async {
    final MessageDto newMessage = event.message;
    int chatIndex = -1;
    RecentChat? chat;
    if (newMessage.chatType == ChatType.singleChat) {
      chatIndex =
          recentChatList.indexWhere((e) => e.chatId == newMessage.senderId);
    } else if (newMessage.chatType == ChatType.groupChat) {
      chatIndex =
          recentChatList.indexWhere((e) => e.chatId == newMessage.groupId);
    }
    if (chatIndex >= 0) {
      chat = recentChatList[chatIndex];
    } else {
      chat = null;
    }

    if (chat != null) {
      chat.unreadCount++;
      allUnReadMsgCount++;
      print("当前全部未读消息数量: $allUnReadMsgCount");
      updateChatBadge();
      chat.lastMessage = _getLastMessage(newMessage);
      chat.lastChatTime = newMessage.sendTime;
      chat.messageType = newMessage.messageType.code;
      recentChatList.removeAt(chatIndex);
      recentChatList.insert(0, chat);
      await _emitAndSaveNewMsg(newMessage, chat, emit);
    } else {
      print("聊天列表中没有这个最近聊天,添加到聊天列表");
      var lastMsg = _getLastMessage(newMessage);
      String chatId = _getChatId(newMessage);
      var newChat = RecentChat(
          chatId: chatId,
          chatType: newMessage.chatType.code,
          lastMessage: lastMsg,
          messageType: newMessage.messageType.code,
          lastChatTime: newMessage.sendTime,
          unreadCount: 1,
          isMute: false,
          isPinned: false,
          updateTime: DateTime.now());
      recentChatList.add(newChat);
      allUnReadMsgCount++;
      updateChatBadge();
      add(AddToChatListEvent(recentChat: newChat));
      await _emitAndSaveNewMsg(newMessage, newChat, emit);
    }
  }

  void updateChatBadge() {
    // 更新聊天图标的红点状态
    final navbarBloc = serviceLocator.get<NavbarBloc>();
    var badgeList = navbarBloc.badgeList;
    badgeList[0] = true;
    navbarBloc.add(UpdateBadgeEvent(badgeList: navbarBloc.badgeList));
  }

  Future _emitAndSaveNewMsg(
      MessageDto newMessage, RecentChat newChat, Emitter emit) async {
    await serviceLocator.get<LocalRecentChatRepo>().saveRecentChat(newChat);
    switch (newMessage.chatType) {
      case ChatType.singleChat:
        //好友的聊天,从本地查找用户信息
        Friend? friend =
            serviceLocator.get<LocalFriendRepo>().getFriend(newChat.chatId);
        if (friend != null) {
          await serviceLocator.get<LocalPrivateMessageRepo>().saveMessage(
              PrivateMessage(
                  friendId: newMessage.senderId,
                  messageId: newMessage.messageId!,
                  content: newMessage.content,
                  mediaUrl: newMessage.mediaUrl,
                  mediaName: newMessage.mediaName,
                  mediaSize: newMessage.mediaSize,
                  isSender: false,
                  messageType: newMessage.messageType.code,
                  status: newMessage.messageStatus.code,
                  sendTime: newMessage.sendTime));
          emit(NewMessageReceived(
            chatItem: ChatItem(
              chatId: newChat.chatId,
              chatName: friend.alias ?? friend.nickname,
              chatType: newMessage.chatType,
              lastMessage: newChat.lastMessage,
              lastChatTime: newChat.lastChatTime,
              avatarUrl: friend.avatar,
              unreadCount: newChat.unreadCount,
              isPinned: false,
            ),
          ));
        }
        break;
      case ChatType.groupChat:
        Group? group =
            serviceLocator.get<LocalGroupRepo>().getGroup(newChat.chatId);
        if (group != null) {
          await serviceLocator.get<LocalGroupMessageRepo>().saveGroupMessage(
              GroupMessage(
                  groupId: newChat.chatId,
                  messageId: newMessage.messageId!,
                  content: newMessage.content,
                  senderId: newMessage.senderId,
                  messageType: newMessage.messageType.code,
                  status: newMessage.messageStatus.code,
                  sendTime: newMessage.sendTime));
          emit(NewMessageReceived(
            chatItem: ChatItem(
                chatId: newChat.chatId,
                chatName: group.groupAlias ?? group.groupName,
                lastMessage: newChat.lastMessage,
                lastChatTime: newChat.lastChatTime,
                chatType: newMessage.chatType,
                avatarUrl: group.groupAvatar,
                unreadCount: newChat.unreadCount,
                isPinned: false),
          ));
          break;
        }
    }
  }

  String _getChatId(MessageDto message) {
    switch (message.chatType) {
      case ChatType.singleChat:
        return message.senderId;
      case ChatType.groupChat:
        return message.groupId!;
    }
  }

  String _getLastMessage(MessageDto newMessage) {
    switch (newMessage.messageType) {
      case MessageType.text:
        return newMessage.content!;
      case MessageType.image:
        return "[图片]";
      case MessageType.file:
        return "[文件]";
      case MessageType.video:
        return "[视频]";
      case MessageType.voice:
        return "[语音]";
      case MessageType.recall:
        return "[对方撤回了一条消息]";
    }
  }

  FutureOr<void> _onAddToChatList(event, emit) async {
    var localFriendRepo = serviceLocator.get<LocalFriendRepo>();
    var localGroupRepo = serviceLocator.get<LocalGroupRepo>();
    var localRecentChatRepo = serviceLocator.get<LocalRecentChatRepo>();
    final RecentChat recentChat = event.recentChat;
    ChatItem? chatItem;
    if (ChatType.singleChat.code == recentChat.chatType) {
      final friend = localFriendRepo.getFriend(recentChat.chatId)!;
      chatItem = ChatItem(
        chatId: recentChat.chatId,
        chatName: friend.alias ?? friend.nickname,
        lastMessage: recentChat.lastMessage,
        lastChatTime: recentChat.lastChatTime,
        avatarUrl: friend.avatar,
        chatType: ChatType.fromCode(recentChat.chatType)!,
        unreadCount: recentChat.unreadCount,
        isPinned: false,
      );
    } else if (ChatType.groupChat.code == recentChat.chatType) {
      final group = localGroupRepo.getGroup(recentChat.chatId)!;
      chatItem = ChatItem(
        chatId: recentChat.chatId,
        chatName: group.groupName,
        lastMessage: recentChat.lastMessage,
        lastChatTime: recentChat.lastChatTime,
        avatarUrl: group.groupAvatar,
        chatType: ChatType.fromCode(recentChat.chatType)!,
        unreadCount: recentChat.unreadCount,
        isPinned: false,
      );
    }
    await localRecentChatRepo.saveRecentChat(recentChat);
    if (chatItem != null) {
      emit(AddToChatListSucceed(chatItem: chatItem));
    }
  }

  FutureOr<void> _onLoadChatList(event, emit) async {
    var localFriendRepo = serviceLocator.get<LocalFriendRepo>();
    var localGroupRepo = serviceLocator.get<LocalGroupRepo>();
    var localRecentChatList =
        serviceLocator.get<LocalRecentChatRepo>().getAllRecentChats();

    if (localRecentChatList.isEmpty) {
      emit(ChatListEmpty());
    } else {
      recentChatList.addAll(localRecentChatList);
      try {
        var chatItemList = localRecentChatList.map((e) {
          allUnReadMsgCount += e.unreadCount;
          var chatType = ChatType.fromCode(e.chatType);
          if (chatType == ChatType.singleChat) {
            var friend = localFriendRepo.getFriend(e.chatId);
            if (friend != null) {
              return ChatItem(
                chatId: e.chatId,
                chatName: friend.alias ?? friend.nickname,
                lastMessage: e.lastMessage,
                lastChatTime: e.lastChatTime,
                avatarUrl: friend.avatar,
                chatType: chatType!,
                unreadCount: e.unreadCount,
                isPinned: e.isPinned,
              );
            }
          } else if (chatType == ChatType.groupChat) {
            var group = localGroupRepo.getGroup(e.chatId);
            if (group != null) {
              return ChatItem(
                  chatId: e.chatId,
                  chatName: group.groupName,
                  lastMessage: e.lastMessage,
                  lastChatTime: e.lastChatTime,
                  avatarUrl: group.groupAvatar,
                  chatType: chatType!,
                  unreadCount: e.unreadCount,
                  isPinned: e.isPinned);
            }
          }
        }).toList();
        //根据是否置顶排序，置顶的排在前面
        chatItemList.sort((a, b) {
          if (a!.isPinned && !b!.isPinned) {
            return -1; // a 在前
          } else if (!a.isPinned && b!.isPinned) {
            return 1; // b 在前
          } else {
            return 0; // 保持原有顺序
          }
        });

        print("最近聊天数量: ${chatItemList.length}");
        emit(LoadChatListSucceed(chatItems: chatItemList));
      } on Exception catch (e) {
        print(e);
        emit(LoadChatListFailed(message: e.toString()));
      }
    }
    on<UpdateRecentChatEvent>((event, emit) async {
      final message = event.message;
      RecentChat? recentChat =
          recentChatList.where((e) => e.chatId == message.senderId).firstOrNull;
      print("触发更新聊天列表的事件,chatId: ${event.message.senderId}");
      //聊天列表中已有
      if (recentChat != null) {
        print("在聊天页面停留时收到了消息,更新chatList页面的记录");
        recentChat.lastChatTime = message.sendTime;
        recentChat.lastMessage = _getLastMessage(message);
        emit(RecentChatUpdated(
            chatId: recentChat.chatId,
            lastMessage: recentChat.lastMessage,
            lastChatTime: recentChat.lastChatTime));
      } else {
        //聊天列表没有,添加到聊天列表
        print("聊天列表中没有最近消息记录,添加到最近消息");
        RecentChat recentChat = RecentChat(
            chatId: message.senderId,
            chatType: message.chatType.code,
            lastMessage: _getLastMessage(message),
            messageType: message.chatType.code,
            lastChatTime: message.sendTime,
            unreadCount: 0,
            isMute: false,
            isPinned: false,
            updateTime: message.sendTime);
        recentChatList.add(recentChat);
        add(AddToChatListEvent(recentChat: recentChat));
      }
    });

    on<DeleteRecentChatEvent>((event, emit) async {
      final chatId = event.chatId;
      var chatIndex = recentChatList.indexWhere((e) => e.chatId == chatId);
      if (chatIndex >= 0) {
        print("在chatList页面删除了聊天项,chatId: ${event.chatId}");
        final recentChat = recentChatList[chatIndex];
        allUnReadMsgCount -= recentChat.unreadCount;
        print("当前全部未读消息数量为: $allUnReadMsgCount");
        recentChat.unreadCount = 0;
        if (allUnReadMsgCount == 0) {
          print("当前页面全部未读消息数量为0,badge清除");
          var badgeList = serviceLocator.get<NavbarBloc>().badgeList;
          badgeList[0] = false;
          serviceLocator
              .get<NavbarBloc>()
              .add(UpdateBadgeEvent(badgeList: badgeList));
        }
        recentChatList.removeAt(chatIndex);
        await serviceLocator
            .get<LocalRecentChatRepo>()
            .deleteRecentChat(chatId);
        emit(DeleteChatSucceed(chatId: chatId));
      } else {
        print("未找到这个聊天项");
      }
    });
  }
}
